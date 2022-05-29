function getFileContent(fileUrl, callback){
   var xhr = new XMLHttpRequest;
   var result = "";
   xhr.open("GET", fileUrl); // set Method and File
   xhr.send(); // begin the request

   xhr.onreadystatechange = function () {
       if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
           var response = xhr.responseText;

           if(callback) callback(response);
       }
   }
}
