/*
 Ayalike's namespaced convenience functions
*/

var AYALIKE = function() {

    return {
        
        redirect: function(url) {
            window.location = url;
        },

        redirectToSiteId: function(siteId) {
            AYALIKE.redirect('/site/show/' + siteId);
        }
    }
}();