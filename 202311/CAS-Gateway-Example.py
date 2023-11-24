import os
import swat

cas_host = os.environ.get('SAS_CAS_SERVER_DEFAULT_CLIENT_SERVICE_HOST')
cas_port = os.environ.get('SAS_CAS_SERVER_DEFAULT_CLIENT_SERVICE_PORT')
token = os.environ.get('SAS_CLIENT_TOKEN')
s = swat.CAS(cas_host, cas_port, password=token)
print(s)

#### Run Gateway

s.loadActionset("gateway")

code = "print('Welcome to the Viya Verse {}'.format(gateway.thread_id))"

s.gateway.runLang(code = code, 
                  single = True) # single thread in a single node

s.gateway.runLang(code = code, 
                  nthreads = 4) # nthreads per node

##### 

code1 = """import pandas as pd
df = pd.read_csv('https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/hmeq.csv')

gateway.write_table(df, {'caslib': 'casuser', 'name': 'hmeq', 'replace':True})

df2 = gateway.read_table({'caslib': 'casuser', 'name': 'hmeq'})
print(df2.head())
"""

s.gateway.runLang(code = code1, 
                  single = True,
                  timeout_millis = 10000)

r = s.table.tableInfo(caslib =  "casuser")
print(r)

# We can also read the data in many sessions. 
# But if you note, this way CAS pushed everything to a single Py session, 
# probably because it is too small.

code2 ="""import pandas as pd
tbl = gateway.read_table({'caslib': 'casuser', 'name': 'hmeq'})
sp = tbl.shape
print('thread_id: {} columns: {} rows: {}'.format(gateway.thread_id, sp[1], sp[0]))
"""

result = s.gateway.runLang(code = code2, 
                     nthreads = 6,
                     timeout_millis = 10000)


# But we can force it to redistribute the data:

code3 ="""import pandas as pd
tbl = gateway.read_table({'caslib': 'casuser', 'name': 'hmeq', 
						'groupby': 'JOB', 'groupbyMode': 'redistribute'})
sp = tbl.shape
print('thread_id: {} columns: {} rows: {} | {}'.format(
		gateway.thread_id, sp[1], sp[0], tbl.JOB.unique())
)
"""

result = s.gateway.runLang(code = code3, 
                     nthreads = 10,
                     timeout_millis = 10000)

## If we need the full table everywhere, we have the special "repeat" argument, 
## which sends the whole table to all the threads

code3_2 = """import pandas as pd
tbl = gateway.read_table({'caslib': 'casuser', 'name': 'hmeq'}, repeat = True)
sp = tbl.shape
print('thread_id: {} columns: {} rows: {} | {}'.format(
		gateway.thread_id, sp[1], sp[0], tbl.JOB.unique())
)
"""

result = s.gateway.runLang(code = code3_2, 
                     nthreads = 10,
                     timeout_millis = 10000)


## If we have atable that is too big and don't want to overload the Python session
## we can read it and write by batches, it will be an arrow batch reader

code3_3 = """
inspec = {'name': 'hmeq', 'caslib': 'casuser'}
outspec = {'name': 'hmeq_batch', 'caslib': 'casuser', 'replace': True}

print("T:{}".format(gateway.thread_id))

with gateway.new_table_writer(outspec) as w:
  with gateway.new_table_reader(inspec, batch_size = 500, repeat = True) as r:
      for df in r:
          lastbatchsize = df.shape[0]
          print(f'Thread {gateway.thread_id}: writing batch of size {lastbatchsize} and writing')
          w.write_batch(df)
"""

result = s.gateway.runLang(code = code3_3, 
                     #single = True,
                     timeout_millis = 10000)
result

print(s.tableInfo(name = "hmeq_batch", caslib = "casuser"))

## Return Table
code5 = """import pandas as pd
import numpy as np

tbl = gateway.read_table({'caslib': 'casuser', 'name': 'hmeq'})

tblName = gateway.args['tblName']
gateway.return_table(tblName, df = tbl, label='ViyaVerseTable', title='mytitle')
"""

result = s.gateway.runLang(code=code5,
                     single=True,
					 args={'tblName': 'ViyaVerse'},
                     timeout_millis= 10000)

rt = result['ViyaVerse']
print(rt)

## R is cool as well
coder = """
print(paste('hello Viya VeRRRse', gw$worker_id))
"""

result = s.gateway.runLang(
					 code=coder,
					 lang= 'r',
                     nthreads = 3)

s.terminate()

os.environ['GW_RPATH'] = None
os.environ['GW_RPATH'] = '/opt/sas/viya/home/sas-pyconfig/default_r/bin/Rscript'