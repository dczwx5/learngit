# 字符串连接
# 高效
list = []
list.append('aa')
list.append('bb')
list.append('cc')
list.append('dd')
strList = ''.join(list)
print('strList : ' + strList)

# 低效
strList = ''
strList += 'aa'
strList += 'bb'
strList += 'cc'
strList += 'dd'
print('strList : ' + strList)

# 替换
baseStr = 'aabbccdd'
baseStr = baseStr.replace('bb', 'kk')
print('replace : newStr : ' + baseStr)