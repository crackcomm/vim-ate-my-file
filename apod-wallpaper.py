import urllib3
from bs4 import BeautifulSoup

http = urllib3.PoolManager()

page = http.request("GET", "https://apod.nasa.gov/apod/astropix.html")
soup = BeautifulSoup(page.data, features="lxml")

x = soup.body.find_all("a")[1].get("href")
url = "https://apod.nasa.gov/apod/%s" % x
image = http.request("GET", url)
f = open("bg.jpg", "wb")
f.write(image.data)
f.close()
