function voteUp(id) {
    vote(id, 1);
}

function voteDown(id) {
    vote(id, -1);
}

function vote(id, change) {
    var votesField = document.getElementById('votes_' + id);
    votesField.value = parseInt(votesField.value) + change;
    makeRequest(id, "/jokes/" + id, "PUT");
}

function deleteJoke(id) {
    makeRequest(id, "/jokes/" + id, "DELETE");
}

function edit(id) {
    toggleEditingControls(true, id);
}

function put(id) {
    toggleEditingControls(false, id);
    makeRequest(id, "/jokes/" + id, "PUT");
}

function post() {
    toggleAddingControls(false);
    makeRequest(-1, "/jokes", "POST");
}

function create() {
    toggleAddingControls(true);
}

function cancel() {
    toggleAddingControls(false);
}

function toggleEditingControls(show, id) {
    var setupField = document.getElementById('setup_' + id);
    var punchlineField = document.getElementById('punchline_' + id);
    var setupText = document.getElementById('setup_text_' + id);
    var punchlineText = document.getElementById('punchline_text_' + id);
    var editButton = document.getElementById('edit_button_' + id);
    var saveButton = document.getElementById('save_button_' + id);
    
    setupText.style.display = show ? "none" : "block";
    punchlineText.style.display = show ? "none" : "block";
    editButton.style.display = show ? "none" : "block";
    
    setupField.style.display = show ? "block": "none";
    punchlineField.style.display = show ? "block": "none";
    saveButton.style.display = show ? "block": "none";
}

function toggleAddingControls(show) {
    var setupField = document.getElementById('setup_create');
    var punchlineField = document.getElementById('punchline_create');
    var editButton = document.getElementById('add_button');
    var saveButton = document.getElementById('save_button_create');
    var createDivider = document.getElementById('create_divider');
    var cancelButton = document.getElementById('cancel_button')

    
    setupField.style.display = show ? "block" : "none"
    punchlineField.style.display = show ? "block" : "none"
    createDivider.style.display = show ? "block" : "none"
    cancelButton.style.display = show ? "block" : "none"

    saveButton.style.display = show ? "block" : "none"
    editButton.style.display = show ? "none" : "block"
    
    if (show) {
        setupField.value = ""
        punchlineField.value = ""
    }
}

// helper functions
function makeRequest(id, url, method) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.addEventListener("load", transferComplete)
    if (method === "PUT") {
        xhr.send(getJSONData(id));
    } else if (method === "POST") {
        xhr.send(getCreateJSONData());
    } else {
        xhr.send()
    }
}

function getJSONData(id) {
    var setupField = document.getElementById('setup_' + id);
    var punchlineField = document.getElementById('punchline_' + id);
    var votesField = document.getElementById('votes_' + id);
    
    return JSON.stringify({ 'id': id, 'setup': setupField.value, 'punchline': punchlineField.value, 'votes': parseInt(votesField.value)});
}

function getCreateJSONData(id) {
    var setupField = document.getElementById('setup_create');
    var punchlineField = document.getElementById('punchline_create');
    
    return JSON.stringify({ 'setup': setupField.value, 'punchline': punchlineField.value, 'votes': 0});
}

function transferComplete(evt) {
    location.reload();
}
