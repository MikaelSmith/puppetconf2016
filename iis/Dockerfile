FROM microsoft/nanoserver

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

COPY iis.pp iis.pp
RUN C:\puppet\bin\puppet.bat apply iis.pp
