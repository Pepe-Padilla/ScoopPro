// api sasurl function:
var azure = require('azure');
var qs = require('querystring');

exports.get = function(request, response) {
    // en el parametro nos llega el nombre del blob
    var blobContainer = request.query.blobContainer;
    var blobName = request.query.blobName;
    var appSettings = azure.service.appSettings;
    var accountName = appSettings.ACCOUNT_NAME;
    var accountKey = appSettings.ACCOUNT_KEY;
    var host = accountName + '.blob.core.windows.net/'
    
    var blobService = azure.createBlobService(accountName, accountKey, host);
    var sharedAccessPolicy = { 
        AccessPolicy : {
            Permissions: 'rw',
            Expiry: minutesFromNow(15)
        }
        
    };
    
    var sasURL = blobService.generateSharedAccessSignature(blobContainer, blobName, sharedAccessPolicy);

    console.log('SAS ->' + sasURL);
     var sasQueryString = { 'sasUrl' : sasURL.baseUrl + sasURL.path + '?' + qs.stringify(sasURL.queryString) };
    request.respond(200, sasQueryString);
        
};

function formatDate(date) { 
    var raw = date.toJSON(); 
    // Blob service does not like milliseconds on the end of the time so strip 
    return raw.substr(0, raw.lastIndexOf('.')) + 'Z'; 
} 

function minutesFromNow(minutes) {
    var date = new Date()
  date.setMinutes(date.getMinutes() + minutes);
  return date;
}