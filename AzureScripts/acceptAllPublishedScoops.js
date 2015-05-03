//Scheduler job
function acceptAllPublishedScoops() {
    var newsTable = tables.getTable('news');
	var whereNews = {"status" : 1};
	var queryResults = "";
	
	var query = newsTable.where(whereNews).read( {
        success: function (results) {
        	queryResults=results;
			for (var i = 0; i < queryResults.length; i++) {
				queryResults[i]["status"] = 2;
                queryResults[i]["rankers"] = 0;
				newsTable.update(queryResults[i]);
			};
		}
	});
}