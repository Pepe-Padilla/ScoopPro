// table news update function
function update(item, user, request) {
    
    delete item["ranking"];
    request.execute();

}