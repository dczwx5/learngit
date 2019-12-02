#coding:utf-8
#/usr/bin/python
import os
import sys
import os.path
import shutil
import shutil
import xml.etree.ElementTree as ET

srcPath = os.getcwd() + '/' + 'bin'

# 遍历所有文件夹
def loopDir(path, callback):
	for root, dirs, files in os.walk(path):   
		for _dir in dirs:
			fulldir = path + '/' + _dir
			callback(fulldir);

# def findPlist(path, callback):    
# 	print "-------------------------------------find plist"    
# 	fromFilePath = path 			# 源路径   
# 	print "fromFilePath=>>>%s" %fromFilePath     
	
# 	for root, dirs, files in os.walk(fromFilePath):        
# 		# print "root = %s" %root        
# 		print "dirs = %s" %dirs 
# 		for _dir in dirs:
# 			fulldir = fromFilePath + '/' + _dir
# 			print 'fulldir %s' %fulldir;
# 		# print "files= %s" %files        

# 		# for name in files:            
# 		# 	fileName, fileSuffix = os.path.splitext(name)            
# 		# 	fromfile =  os.path.join(root,name) 
# 		# 	hasPlist = 0;
# 		# 	if fileSuffix == '.plist':                
# 		# 		hasPlist = 1
# 		# 	if (hasPlist > 0):
# 	callback('1');
			
				
# def removeSpecialDirs(path):    
# 	print "-------------------------------------remove anitions spines" 
# 	fromFilePath = path 			# 源路径   
# 	print "fromFilePath=%s" %fromFilePath     
	
# 	for root, dirs, files in os.walk(fromFilePath):        
# 		for dir in dirs :
# 			fulldir = os.path.join(root, dir);
# 			if dir == 'animations' or dir == 'spines':
# 				shutil.rmtree(fulldir)
# 				#print 'ok'
# 				#print "removedir %s" %dir
				
# def removeEmptyDir(path):    
# 	print "-------------------------------------removeEmptyDir"    
# 	fromFilePath = path 			# 源路径   
# 	print "fromFilePath=%s" %fromFilePath     
	
# 	for root, dirs, files in os.walk(fromFilePath):        
# 		for dir in dirs :
# 			fulldir = os.path.join(root, dir);
# 			if not os.listdir(fulldir):  #判断文件夹是否为空
# 				os.rmdir(fulldir)

def processPlist(plistName):
	tree = ET.parse(plistName)
	plist = tree.getroot()
	plistDict = plist.find('dict')

	# 找出 key<frames> -> dict
	nextNodeIsContent = 0

	for nodeItem in plistDict:
		if (1  == nextNodeIsContent):
			print ('find content : ')
			findItem = nodeItem
			break
		if (nodeItem.text == 'frames'):
			nextNodeIsContent = 1

	# 找出item 和 offset
	allData = []
	if (1 == nextNodeIsContent):
		nextNodeIsContent = 0
		for item in findItem:
			if item.tag == 'key':
				imgName = item.text

			if item.tag == 'dict':
				offset = []
				for subItem in item:
					if (1 == nextNodeIsContent):
						# offset坐标
						offsetContent = subItem.text
						pos = getOffsetPos(offsetContent)

						break;

					if subItem.text == 'frame':
						nextNodeIsContent = 1
				objData = {'name':imgName, 'offset':pos}
				# print objData
				allData.append(objData)
				nextNodeIsContent = 0
	print allData
	return allData

def processDir(_dir):
	for root, dirs, files in os.walk(_dir):
		hasPlist = 0
		for name in files:            
			fileName, fileSuffix = os.path.splitext(name)

			plistName =  os.path.join(root,name) 
			if fileSuffix == '.plist':
				hasPlist = 1;
				break;
		if (hasPlist) :
			imgDataList = processPlist(plistName)
			saveFntFile(fileName, root, imgDataList)

def saveFntFile(fileName, dir, imgDataList):
	print 'savefile=========================='
	saveName = os.path.join(dir, fileName+'.fnt')

	size = 32
	imgw = 256
	imgh = 256
	count = len(imgDataList)
	str = 'info face="Arial" size={} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0 \
	\ncommon lineHeight={} base=26 scaleW={} scaleH={} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0 \
	\npage id=0 file="{}" \
	\nchars count={}'
	str = str.format(size, size, imgw, imgh, fileName+'.png', count)
	
	itemStrAll = ''
	for item in imgDataList:
		itemName = item['name']
		imgName = spliteImageName(itemName)

		asciiId = getAscii(imgName)

		pos = item['offset']
		x = pos[0]
		y = pos[1]
		w = pos[2]
		h = pos[3]
		itemStr = 'char id={}   x={}     y={}    width={}    height={}    xoffset=0     yoffset=0     xadvance={}    page=0  chnl=15'
		itemStr = itemStr.format(asciiId, x, y, w, h, w)
		itemStrAll += itemStr + '\n'
	# char id=48 x=0 y=0 width=16 height=22 xoffset=0 yoffset=0 xadvance=16 page=0 chnl=15

	str += '\n' + itemStrAll
	print str
	with open(saveName, 'w') as fw :
		fw.write(str);

def getAscii(char) :
	asciiId = 0
	if char == 'slanting' :
		asciiId = 47
	elif char == 'star' :
		asciiId = 42
	else :
		asciiId = ord(char)
	return asciiId;

def spliteImageName(imageName) :
	ret = imageName.rfind('.')
	ret = imageName[0:ret]
	return ret

def getOffsetPos(offsetStr):
	str = offsetStr
	str = str.replace('{', '')
	str = str.replace('}', '')
	pset = str.split(',')
	iList = [1,2,3,4]
	iList[0] = int(pset[0])
	iList[1] = int(pset[1])
	iList[2] = int(pset[2])
	iList[3] = int(pset[3])
	return iList
				
if __name__ == "__main__":   
	print "\n\n\n"
	# removeNotPng(srcPath) # 删除非png
	# removeSpecialDirs(srcPath) # 删除指定不压缩的目录, anitaions, spines,
	
	# # 多次执行为了尽量保证有一些空文件夹没有删除, 如果太多层的话。就加多执行几次
	# removeEmptyDir(srcPath)
	# removeEmptyDir(srcPath)
	# removeEmptyDir(srcPath)
	# removeEmptyDir(srcPath)
	# removeEmptyDir(srcPath)
	# removeEmptyDir(srcPath)
	# find xml
	loopDir(srcPath, processDir);
	# 生成fnt
	


