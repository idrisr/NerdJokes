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
    var xhr = new XMLHttpRequest();
    var url = "/jokes/" + id;
    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.addEventListener("load", transferComplete)
    xhr.send(getJSONData(id));
}

function getJSONData (id) {
    var form = document.getElementById('form_modify_' + id);
    var setupField = document.getElementById('setup_' + id);
    var punchlineField = document.getElementById('punchline_' + id);
    var votesField = document.getElementById('votes_' + id);
    
    return JSON.stringify({ 'id': id, 'setup': setupField.value, 'punchline': punchlineField.value, 'votes': parseInt(votesField.value)});
}

function transferComplete(evt) {
    location.reload();
}
