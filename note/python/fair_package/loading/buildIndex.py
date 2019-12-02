  #coding:utf-8
#/usr/bin/python
import os
import sys
import os.path
import time

# 主目录
m_dirName = 'fair'
if len(sys.argv) > 1:
	  m_dirName = sys.argv[1]
m_dirPath = '../' + m_dirName + '/'

# index.html 保存目录
m_indexPath = '../' + m_dirName + '/index.html'

# config 替换ip
m_ipRedirect = None # 'www.hbspace.net' # None
if len(sys.argv) > 2:
	m_ipRedirect = sys.argv[2]

# template
m_indexTemplateName = 'index_template'
m_configTemplateName = 'configs_template'

# save 
m_saveConfigName = None
m_baseConfigName = 'configs'

m_allList = ['bundle', 'SFS2X_API_JS', 'laya.core', 'laya.webgl', 'laya.ui', 'index']
m_nameFlagList = ['var ____BUNDLE____', 'var ____SFS2X_API_JS____', 'var ____CORE____', 'var ____WEBGL____', 'var ____UI____', 'var ____INDEX____']
m_nameFlagReplaceList = ['____BUNDLE____', '____SFS2X_API_JS____', '____CORE____', '____WEBGL____', '____UI____', '____INDEX____']
m_srcIndexHtmlContent = '' # 读出来的htmlContent

def get_base_name_by_fliename(filename):
	for baseName in m_allList:
		if is_same(baseName, filename):
			return baseName
	return None

def is_same(baseName,fileName) :
	baseNameLen = len(baseName)
	sTempFileName = fileName[0:baseNameLen]
	if sTempFileName == baseName :
		return True
	return False
	
def reName(baseName, newName) :
	m_allListLen = len(m_allList)
	for i in range(m_allListLen):
		baseName = m_allList[i]
		bSame = is_same(baseName, newName)
		if bSame :
			global m_nameFlagReplaceList
			m_nameFlagReplaceList[i] = newName
	
def loopAllFile(path, loopHandler):    
	fromFilePath = path 			# 源路径   
	print "fromFilePath=%s" %fromFilePath     
	
	for root, dirs, files in os.walk(fromFilePath, loopHandler):     
		if loopHandler is None :
			return
		for name in files:            
			fileName, fileSuffix = os.path.splitext(name)   
			fullUrl =  os.path.join(root,name) 
			loopHandler(fileName, fileSuffix, fullUrl)
			
def loopJsHandler(fileName, fileSuffix, fullUrl) :
	if fileSuffix == '.js' :
		# 其他js
		baseName = get_base_name_by_fliename(fileName)
		if baseName is not None :
			# ok
			reName(baseName, fileName)
def loopConfigHandler(fileName, fileSuffix, fullUrl) :
	if fileSuffix == '.json' :
		# 其他js
		if is_same(m_baseConfigName, fileName) :
			global m_saveConfigName
			m_saveConfigName = fileName

# if __name__ == "__main__":
# 找出所有js, 找出js名字
loopAllFile(m_dirPath, loopJsHandler);

# 读template.index文件
with open(m_indexTemplateName+'.html', 'r') as f:
	m_srcIndexHtmlContent = f.read()

# 替换index.html里所变量
while True:
	srcLen = len(m_srcIndexHtmlContent)
	if srcLen > 10 :		
		listLen = len(m_nameFlagList)
		for i in range(listLen) :
			srcFlag = m_nameFlagList[i]
			newFlag = srcFlag + ' = ' + '\'' + m_nameFlagReplaceList[i] + '.js\''
			m_srcIndexHtmlContent = m_srcIndexHtmlContent.replace(srcFlag, newFlag)
		with open(m_indexPath, 'w') as fw :
			fw.write(m_srcIndexHtmlContent)
			
		break
	time.sleep(1)

# 修改config文件的ip
if m_ipRedirect is not None:
	confDir = m_dirPath + 'conf/';
	configBase = ''
	# 获得config文件名
	loopAllFile(confDir, loopConfigHandler)
	confURL = confDir + m_saveConfigName + '.json'

	# 读configs 模板, 并替换ip
	with open('configs_template.json', 'r') as fr :
		configBase = fr.read();
	configBase = configBase.replace('____IP____', '\"' + m_ipRedirect + '\"')
	
	# 写入新的config
	print(confURL)
	with open(confURL, 'w') as fw :
		fw.write(configBase);
	

