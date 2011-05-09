// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var Application = {
  authenticityToken: function() {
    return $('authenticity-token').content;
  },

  authenticityTokenParameter: function(){
   return 'authenticity_token=' + encodeURIComponent(Application.authenticityToken());
  }
}

function do_remote_call(divID, divAction, asynch){
	new Ajax.Updater(divID, divAction, {asynchronous: asynch, evalScripts:true, parameters: Application.authenticityTokenParameter()});	
	
}


function wait(millis)
{
	var date = new Date();
	var curDate = null;

	do { curDate = new Date(); }
	while(curDate-date < millis);
}

Array.prototype.find = function(searchStr) {
  var returnArray = false;
  for (i=0; i<this.length; i++) {
    if (typeof(searchStr) == 'function') {
      if (searchStr.test(this[i])) {
        if (!returnArray) { returnArray = [] }
        returnArray.push(i);
      }
    } else {
      if (this[i]===searchStr) {
        if (!returnArray) { returnArray = [] }
        returnArray.push(i);
      }
    }
  }
  return returnArray;
}