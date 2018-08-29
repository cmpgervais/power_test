callAPI = function(uid,url,pwd=NA,verbose=F){
  require(RCurl)
  require(bit64)
  require(data.table)
  if(is.na(pwd)){pwd = .rs.askForPassword('Password')}
  http.pos = regexpr('https://', url)
  if(http.pos<0){url = paste0('https://',url)}
  userpwd = paste0(curlEscape(uid),':',curlEscape(pwd))
  url = paste0(substr(url,1,8),userpwd,'@',substr(url,9,nchar(url)))
  data = fread(url,showProgress = verbose, integer64 = 'numeric')
  return(data)
}

uid = 'algonquin1'
pwd = "Newhome22"