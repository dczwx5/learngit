#coding:utf-8
#/usr/bin/python
import os
import sys
import os.path
import shutil
import tinify 
import shutil

srcPath = os.getcwd() + '/' + 'bin'

def removeNotPng(path):    
	print "-------------------------------------remove no png"    
	fromFilePath = path 			# 源路径   
	print "fromFilePath=%s" %fromFilePath     
	
	for root, dirs, files in os.walk(fromFilePath):        
		# print "root = %s" %root        
		# print "dirs = %s" %dirs        
		# print "files= %s" %files        
		for name in files:            
			fileName, fileSuffix = os.path.splitext(name)            
			fromfile =  os.path.join(root,name) 
			if fileSuffix == '.png':                
				nothing = 1    	  
			else :
				os.remove(fromfile)
				
def removeSpecialDirs(path):    
	print "-------------------------------------remove anitions spines" 
	fromFilePath = path 			# 源路径   
	print "fromFilePath=%s" %fromFilePath     
	
	for root, dirs, files in os.walk(fromFilePath):        
		for dir in dirs :
			fulldir = os.path.join(root, dir);
			if dir == 'animations' or dir == 'spines':
				shutil.rmtree(fulldir)
				#print 'ok'
				#print "removedir %s" %dir
				
def removeEmptyDir(path):    
	print "-------------------------------------removeEmptyDir"    
	fromFilePath = path 			# 源路径   
	print "fromFilePath=%s" %fromFilePath     
	
	for root, dirs, files in os.walk(fromFilePath):        
		for dir in dirs :
			fulldir = os.path.join(root, dir);
			if not os.listdir(fulldir):  #判断文件夹是否为空
				os.rmdir(fulldir)
		  
			
				
if __name__ == "__main__":   
	removeNotPng(srcPath) # 删除非png
	removeSpecialDirs(srcPath) # 删除指定不压缩的目录, anitaions, spines,
	
	# 多次执行为了尽量保证有一些空文件夹没有删除, 如果太多层的话。就加多执行几次
	removeEmptyDir(srcPath)
	removeEmptyDir(srcPath)
	removeEmptyDir(srcPath)
	removeEmptyDir(srcPath)
	removeEmptyDir(srcPath)
	removeEmptyDir(srcPath)