// table news insert function
function insert(item, user, request) {

    delete item["id"];
    
    if (item["titlescoop"] == null || item["authorid"] == null || item["titlescoop"] == "" || item["authorid"] == "") 
    {
        request.respond(statusCodes.BAD_REQUEST, 
            "title or authorID error");
    } else request.execute();

}