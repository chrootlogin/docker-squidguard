# SquidGuard

Minimal SquidGuard docker image with integrated filter lists based on [rootlogin/squid](https://github.com/chrootLogin/squidguard).

[![](https://images.microbadger.com/badges/version/rootlogin/squidguard.svg)](https://microbadger.com/images/rootlogin/squidguard "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/rootlogin/squidquard.svg)](https://microbadger.com/images/rootlogin/squidguard "Get your own image badge on microbadger.com")

This image is meant for blocking unwanted content in a private or corporate network. The blocklists are contained in the docker image, so you have to rebuild it yourself and create a child-image to modify the block settings. It uses the [shallalist](http://shallalist.de). If you want to integrate this image in a commercial solution you have to ask them for a license.

Default blocked categories are:
* **adv**: Advertisments
* **aggressive**: Aggressive content
* **porn**: Pornografic content
* **spyware**: Sites with spyware
* **violence**: Sites with violence
* **warez**: Illegal content like warez and keygens.

To see other available categories see: [http://www.shallalist.de/categories.html](http://www.shallalist.de/categories.html).

## Usage

It's recommended that you use host networking when running squid, so that you can see the source IP in the logs. Otherwise you will see the IP of your docker host.

```
docker run --net=host --name=myproxy rootlogin/squidguard
```

Default blocking is by redirecting the proxy user to [duckduckgo.com](https://duckduckgo.com). To customize this, set the REDIRECT_URL environment variable:
```
docker run --net=host --name=myproxy -e "REDIRECT_URL=http://myblockpage.com" rootlogin/squidguard
```

To use this proxy, configure your environment or operating system correctly:

```
export http_proxy=http://PROXY_HOST:3128
export https_proxy=http://PROXY_HOST:3128
```

**Port 3128** is default.

### Volumes

* **/cache**: Here goes the squid cache
* **/logs**: Here goes the squid logs

## Configuration

### Squid (Proxy)

If you want to configure things like authentication, you should overwrite the default squid configuration. You can do this either by using the volume function of docker, or by creating a child image. You should use the included configuration as base.

**Via Volume**
```
docker run --net=host --name=myproxy -v ./mysquid.conf:/etc/squid/squid.conf rootlogin/squidguard
```

**Via childimage**
```
FROM rootlogin/squidguard

COPY mysquid.conf /etc/squid/squid.conf
```

### SquidGuard (Blocklist)

For modifying the block lists the best way is to use a child-image.

Create a new Dockerfile:
```
FROM rootlogin/squidguard

ARG BLOCKED_CATEGORIES=adv,spyware,violence,warez

RUN /create-blocklist.sh
```

Then do `docker build -t myproxy_image .` and `docker run --net=host --name=myproxy myproxy_image`
