#coding:utf-8
#/usr/bin/python
import os
import sys
import os.path
import shutil
import tinify 
srcPath = os.getcwd() + '/' + 'img_src'
destPath = os.getcwd()+'/'+'img_dest'			#临时目录,注意该脚本最后是要删掉这个临时目录的
tinify.key = "SWPSl1gJX7wz1NKXdxw3cWcYJhxYh81z"		# 刚刚申请的API KEY
version = "0.0.1"				# 版本 

# 压缩的核心
def compress_core(inputFile, outputFile, img_width):	
	source = tinify.from_file(inputFile)	
	if img_width is not -1:		
		resized = source.resize(method = "scale", width  = img_width)		
		resized.to_file(outputFile)	
	else:		
		source.to_file(outputFile) 
		
# 压缩一个文件夹下的图片
def compress_path(path, width):    
	print "compress_path-------------------------------------"    
	fromFilePath = path 			# 源路径   
	print "fromFilePath=%s" %fromFilePath     
	
	for root, dirs, files in os.walk(fromFilePath):        
		print "root = %s" %root        
		print "dirs = %s" %dirs        
		print "files= %s" %files        
		for name in files:            
			fileName, fileSuffix = os.path.splitext(name)            
			if fileSuffix == '.png' or fileSuffix == '.jpg' or fileSuffix == '.jpeg':                
				fromfile =  os.path.join(root,name)   

				newDestPath = root.replace('img_src', 'img_dest')
				print newDestPath
				if not os.path.exists(newDestPath):        
					os.mkdir(newDestPath)
				
				tofile = os.path.join(newDestPath,name)                
				print fromfile                
				print  tofile                
				compress_core(fromfile, tofile, width)                
				# shutil.copy2(tofile, fromfile)# 将压缩后的文件覆盖原文件   
				
if __name__ == "__main__":    
	    
	compress_path(srcPath, -1)
