// api rankscoop function:
// rankscoop with get
exports.get = function(request, response) {
   console.log(request.query);
    var tables = request.service.tables;
    var newsTable = tables.getTable('news');
    var scoopId = request.query["id"];
    var ranking = parseFloat(request.query["ranking"]);
    //var rankers = parseFloat(request["rankers"]);
    
    var whereNews = {"id": scoopId};

    var query = newsTable.where(whereNews).read( {
        success: function (results) {
            var queryResults=results;

            var actualRanking = parseFloat(queryResults[0]["ranking"]);
            var actualRankers = parseInt(queryResults[0]["rankers"]);

            queryResults[0]["ranking"] = ((actualRankers * actualRanking) + ranking) / (actualRankers + 1);
            queryResults[0]["rankers"] = actualRankers+1;
            newsTable.update(queryResults[0]);
            response.send(200, queryResults[0]); 
        }
    });
};