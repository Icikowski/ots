securePassword = null

createSecret = () ->
  secret = $('#formCreateSecret').find('textarea').val()

  securePassword = Math.random().toString(36).substring(2)
  secret = GibberishAES.enc(secret, securePassword)

  $.ajax 'api/create',
    method: "post"
    data:
      secret: secret
    dataType: "json"
    statusCode:
      201: secretCreated
      400: somethingWrong
      500: somethingWrong
      404: () ->
        # Mock for interface testing
        secretCreated
          secret_id: 'foobar'

  false

dataNotFound = () ->
  $('#notfound').show()

hashLoad = () ->
  hash = window.location.hash
  if hash.length == 0
    return

  $('#cardNewSecret').hide()
  $('#cardSecretURL').hide()
  $('#notfound').hide()
  $('#somethingwrong').hide()
  $('#cardReadSecretPre').show()

requestSecret = () ->
  hash = window.location.hash
  hash = decodeURIComponent(hash)

  parts = hash.split '|'
  if parts.length == 2
    hash = parts[0]
    securePassword = parts[1]

  id = hash.substring(1)
  $.ajax "api/get/#{id}",
    dataType: "json"
    statusCode:
      404: dataNotFound
      200: showData

initBinds = () ->
  $('#formCreateSecret').bind 'submit', createSecret
  $('#newSecret, .navbar-brand').bind 'click', newSecret
  $(window).bind 'hashchange', hashLoad
  $('#revealSecret').bind 'click', requestSecret

newSecret = () ->
  location.href = location.href.split('#')[0]
  false

secretCreated = (data) ->
  secretHash = data.secret_id
  if securePassword != null
    secretHash = "#{secretHash}|#{securePassword}"
  url = "#{location.href.split('#')[0]}##{secretHash}"

  $('#cardNewSecret').hide()
  $('#cardReadSecretPre').hide()
  $('#cardSecretURL').show()
  $('#cardSecretURL').find('input').val url
  $('#cardSecretURL').find('input').focus()
  $('#cardSecretURL').find('input').select()

  securePassword = null

showData = (data) ->
  secret =  data.secret
  if securePassword != null
    secret = GibberishAES.dec(secret, securePassword)

  $('#cardNewSecret').hide()
  $('#cardSecretURL').hide()
  $('#notfound').hide()
  $('#somethingwrong').hide()
  $('#cardReadSecretPre').hide()
  $('#cardReadSecret').show()
  $('#cardReadSecret').find('textarea').val secret

somethingWrong = () ->
  $('#somethingwrong').show()


$ ->
  initBinds()
  hashLoad()
