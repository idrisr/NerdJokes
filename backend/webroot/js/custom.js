function voteUp (id) {
    vote(id, 1);
}

function voteDown (id) {
    vote(id, -1);
}

function vote(id, change) {
    var votesField = document.getElementById('votes_' + id);
    votesField.value = parseInt(votesField.value) + change;
    makeRequest(id);
}

function makeRequest (id) {
    var xhr = new XMLHTTPRequest();
    var url = "/jokes/" + id;
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        location.reload();
    };
    xhr.data = getJSONData(id);
    xhr.send(data)
}

function getJSONData (id) {
    var form = document.getElementById('form_modify_' + id);
    var setupField = document.getElementById('setup_' + id);
    var punchlineField = document.getElementById('punchline_' + id);
    var votesField = document.getElementById('votes_' + id);
    
    return JSON.stringify({ 'id': id, 'setup': setupField.value, 'punchline': punchlineField.value, 'votes': votesField.value});
}
