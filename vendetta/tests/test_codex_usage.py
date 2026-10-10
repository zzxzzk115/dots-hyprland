import runpy,json,time,tempfile,unittest
from pathlib import Path
from datetime import datetime,timezone
from unittest.mock import patch
m=runpy.run_path(str(Path(__file__).resolve().parents[1]/'optional/bin/codex-usage'));f=m['news_status'];now=time.time()
def iso(t):return datetime.fromtimestamp(t,timezone.utc).isoformat()
def fixture():return {'updated':now,'forecast':{'updated_at':iso(now),'last_reset_at':iso(now-86400),'official_signal':{'tweet_id':'123456','at':iso(now-60),'summary':'We will reset usage soon.','url':'https://x.com/thsottiaux/status/123456','window':{'label':'Within an hour','end_at':iso(now+3600)}}}}
class NewsTests(unittest.TestCase):
 def test_future(self):self.assertTrue(f(fixture(),now)['upcoming'])
 def test_predictions(self):
  d=fixture();d['forecast']['official_signal']=None;d['forecast']['probabilities']={'rounded_24h':99};self.assertFalse(f(d,now)['upcoming'])
 def test_banked(self):
  d=fixture();d['forecast']['official_signal']['summary']='A banked reset is coming';self.assertFalse(f(d,now)['upcoming'])
 def test_expired(self):self.assertFalse(f(fixture(),now+4000)['upcoming'])
 def test_already_reset(self):
  d=fixture();d['forecast']['last_reset_at']=iso(now);self.assertFalse(f(d,now)['upcoming'])
 def test_unknown_window(self):
  d=fixture();d['forecast']['official_signal']['window']={};self.assertFalse(f(d,now)['upcoming'])
 def test_bad_source(self):
  d=fixture();d['forecast']['official_signal']['url']='file:///tmp/test';self.assertFalse(f(d,now)['upcoming'])
 def test_stale(self):
  d=fixture();d['error']='offline';self.assertFalse(f(d,now)['upcoming']);d.pop('error');d['forecast']['updated_at']=iso(now-1000);self.assertFalse(f(d,now)['upcoming'])
 def test_dedup_and_snooze(self):
  fn=m['remind_news'];g=fn.__globals__
  with tempfile.TemporaryDirectory() as t:
   base=Path(t);news=base/'news.json';news.write_text(json.dumps(fixture()));settings=base/'settings.json'
   with patch.dict(g,BASE=base,NEWS=news,NEWS_SENT=base/'sent.json',SETTINGS=settings,read=lambda:{'updated':now,'windows':[{'remaining':70,'resetsAt':now+40000}]}):
    with patch.object(g['subprocess'],'run') as run:
     run.return_value.returncode=0;fn();fn();self.assertEqual(run.call_count,1)
     (base/'sent.json').unlink();settings.write_text(json.dumps({'enabled':True,'snoozedUntil':now+86400}));fn();self.assertEqual(run.call_count,1)
if __name__=='__main__':unittest.main()
