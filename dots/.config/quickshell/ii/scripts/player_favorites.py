#!/usr/bin/env python3
"""Quickshell adapter for OmniLyrics' shared favorites API. No player credentials."""
import argparse
import ipaddress
import json
import os
from pathlib import Path
import re
import urllib.error
import urllib.request


class FavoriteError(Exception):
    pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def service_address():
    folder = Path(os.environ.get('OMNILYRICS_CONFIG_DIR') or str(Path.home() / '.config/omnilyrics'))
    try:
        try:
            server = json.loads((folder / 'config.json').read_text()).get('server', {})
        except FileNotFoundError:
            server = {}
        host = os.environ.get('OMNILYRICS_CONTROL_HOST') or server.get('controlHost', '127.0.0.1')
        port = int(os.environ.get('OMNILYRICS_HTTP_PORT') or server.get('httpPort', 27270))
        if not isinstance(host, str) or not 1 <= port <= 65535:
            raise ValueError()
        if ':' in host:
            host = '[' + str(ipaddress.IPv6Address(host.strip('[]'))) + ']'
        elif not re.fullmatch(r'[A-Za-z0-9.-]+', host):
            raise ValueError()
        return f'http://{host}:{port}'
    except (OSError, ValueError, TypeError, AttributeError):
        raise FavoriteError('invalid_config') from None


def identity(state):
    if not isinstance(state, dict) or not state.get('title'):
        raise FavoriteError('no_track')
    return tuple(json.dumps(state.get(k), sort_keys=True) for k in ('sourceApp', 'title', 'artists', 'album'))


def validate_favorite(value):
    if (not isinstance(value, dict) or not isinstance(value.get('trackId'), str)
            or not value['trackId'] or not isinstance(value.get('mediaKey'), str)
            or not value['mediaKey'] or type(value.get('isFavorite')) is not bool):
        raise FavoriteError('invalid_response')
    return {k: value[k] for k in ('trackId', 'mediaKey', 'isFavorite')}


class FavoritesClient:
    def __init__(self, address):
        self.base = address
        self.http = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())

    def request(self, path, body=None):
        headers = {'Accept': 'application/json'}
        payload = None
        if body is not None:
            headers['Content-Type'] = 'application/json'
            payload = json.dumps(body).encode()
        request = urllib.request.Request(self.base + path, data=payload, headers=headers)
        try:
            with self.http.open(request, timeout=45 if body is not None else 25) as response:
                value = json.load(response)
            if not isinstance(value, dict):
                raise FavoriteError('invalid_response')
            return value
        except urllib.error.HTTPError as error:
            code = error.code
            error.close()
            raise FavoriteError('track_changed' if code == 409 else 'not_supported' if code == 404 else 'request_failed') from None
        except (urllib.error.URLError, TimeoutError, OSError):
            raise FavoriteError('unavailable') from None
        except (ValueError, UnicodeError):
            raise FavoriteError('invalid_response') from None

    def state(self):
        snapshot = self.request('/snapshot')
        if snapshot.get('service') != 'OmniLyrics' or snapshot.get('protocolVersion') != 1:
            raise FavoriteError('invalid_response')
        state = snapshot.get('state')
        identity(state)
        return state

    def finish(self, before, favorite):
        after = self.request('/playback/state')
        if identity(before) != identity(after):
            raise FavoriteError('track_changed')
        return {'available': True, 'title': after['title'],
                'artist': ', '.join(after.get('artists') or []), 'album': after.get('album') or '',
                'sourceApp': after.get('sourceApp') or '', 'favorite': favorite['isFavorite'],
                'previous': favorite}

    def status(self):
        before = self.state()
        favorite = validate_favorite(self.request('/favorites'))
        return self.finish(before, favorite)

    def set_favorite(self, expected, favorite):
        previous = validate_favorite(expected.get('previous'))
        before = self.state()
        # Check the displayed widget before forwarding the server's opaque identity.
        current = {'title': before['title'], 'artist': ', '.join(before.get('artists') or []),
                   'album': before.get('album') or '', 'sourceApp': before.get('sourceApp') or ''}
        if any(current[k] != expected.get(k) for k in current):
            raise FavoriteError('track_changed')
        confirmed = validate_favorite(self.request('/favorites', {'previous': previous, 'favorite': favorite}))
        if any(confirmed[k] != previous[k] for k in ('trackId', 'mediaKey')):
            raise FavoriteError('track_changed')
        if confirmed['isFavorite'] != favorite:
            raise FavoriteError('not_confirmed')
        return self.finish(before, confirmed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('status')
    change = commands.add_parser('set')
    change.add_argument('expected')
    change.add_argument('favorite', choices=('0', '1'))
    args = parser.parse_args()
    try:
        client = FavoritesClient(service_address())
        result = client.status() if args.command == 'status' else client.set_favorite(json.loads(args.expected), args.favorite == '1')
    except FavoriteError as error:
        result = {'available': False, 'error': str(error)}
    except (ValueError, TypeError, AttributeError, KeyError):
        result = {'available': False, 'error': 'invalid_response'}
    print(json.dumps(result, ensure_ascii=False), flush=True)


if __name__ == '__main__':
    main()
