This directory is a modified installation of the California Digital
Library’s [eXtensible Text Framework](https://xtf.cdlib.org/). In
particular, we started with [version
3.1](https://xtf.cdlib.org/wp-content/uploads/2012/07/xtf-3.1.war).

I (Syd) am not entirely sure how you are _supposed_ to use this
directory. I have discovered, however, that if you just copy it
to sit alongside another pre-existing XTF directory, it works just
fine. E.g.
```bash
$ cp -pr /path/to/this/git/repo/xtf /var/lib/tomcat8/webapps/Richelieu_Web_Archive
```
You may need to change the owner and permissions to some files, e.g.:
```bash
$ cd /var/lib/tomcat8/webapps/Richelieu_Web_Archive
$ sudo chgrp -R tomcat8 index/  &&  sudo chmod -R g+w index/
```

