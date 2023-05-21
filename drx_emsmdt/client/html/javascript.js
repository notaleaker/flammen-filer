const drx_emsmdt = new Vue({
    el: '#DRX_EMSMDT',
    vuetify: new Vuetify(),

    data: () => ({
        isOpen: false,
        CurrentPage: 'Current',
        Pages: ['Current', 'Calls', 'Database'],
        // Users information
        charname: null,
        status: null,

        // Calls
        calls: {},
        current_call: {
            incident: null,
            identifier: null,
            type: null,
            message: null,
            date: null,
            location: null,
            coords: null,
            charname: null,
            phonenumber: null,
        },
        respondOverlay: false,
        zrespondOverlay: 0,
        respondMessage: null,

        // Database
        searchResults: {},
        searchInput: '',
        selected_person: {
            identifier: null,
            firstname: null,
            lastname: null,
            phonenumber: null,
            database: {},
        },
        newcaseOverlay: false,
        znewcaseOverlay: 0,
        new_case: {
            title: null,
            desc: null,
        },
        viewcaseOverlay: false,
        zviewcaseOverlay: 0,
        view_case: {
            id: null,
            identifier: null,
            patientName: null,
            author: null,
            title: null,
            desc: null,
        },
    }),

    methods: {
        openMenu(charname, status, calls) {
            this.isOpen = true;
            this.CurrentPage = 'Current';
            this.charname = charname;
            this.status = status;
            this.calls = calls;
        },
        closeMenu() {
            this.isOpen = false;
            this.respondOverlay = false;
            this.newcaseOverlay = false;
            $.post('http://drx_emsmdt/close');
        },
        ChangePage(Pages) {
            this.CurrentPage = Pages;
            this.respondOverlay = false;
            this.newcaseOverlay = false;
        },



        // Current
        UpdateStatusAvailable(Available) {
            if (this.status === Available) {
                $.post('http://drx_emsmdt/message', JSON.stringify({
                    type: 'inform',
                    message: 'Your status is already as available'
                }))
            } else {
                this.status = 'Available';
                $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                    status: 'Available'
                }))
            }
        },
        UpdateStatusUnavailable(Unavailable) {
            if (this.status === Unavailable) {
                $.post('http://drx_emsmdt/message', JSON.stringify({
                    type: 'inform',
                    message: 'Your status is already as Unavailable'
                }))
            } else {
                this.status = 'Unavailable';
                $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                    status: 'Unavailable'
                }))
            }
        },
        UpdateStatusBusy(Busy) {
            if (this.status === Busy) {
                $.post('http://drx_emsmdt/message', JSON.stringify({
                    type: 'inform',
                    message: 'Your status is already as Busy'
                }))
            } else {
                this.status = 'Busy';
                $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                    status: 'Busy'
                }))
            }
        },


        // Calls
        AttachCall(index) {
            if (this.status == 'Available') {
                $.post('http://drx_emsmdt/attachToCall', JSON.stringify({
                    coords: this.calls[index].coords
                }));
                this.current_call = this.calls[index]
                this.CurrentPage = 'Current'
                this.status = 'Busy';
                $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                    status: 'Busy'
                }))
            } else {
                $.post('http://drx_emsmdt/message', JSON.stringify({
                    type: 'error',
                    message: 'Update your status as available first'
                }))
            }
        },
        DetachCall() {
            $.post('http://drx_emsmdt/detachFromCall');
            this.current_call = {
                incident: null,
                identifier: null,
                type: null,
                message: null,
                date: null,
                location: null,
                coords: null,
                charname: null,
                phonenumber: null,
            }
            this.status = 'Available';
            $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                status: 'Available'
            }))
        },
        SetWaypoint() {
            $.post('http://drx_emsmdt/setWaypoint', JSON.stringify({
                coords: this.current_call.coords
            }));
        },
        RespondCall() {
            $.post('http://drx_emsmdt/responCall', JSON.stringify({
                incident: this.current_call.incident,
                identifier: this.current_call.identifier,
                msg: this.respondMessage
            }))
        },
        DeleteCall() {
            $.post('http://drx_emsmdt/deleteCall', JSON.stringify({
                incident: this.current_call.incident
            }))
            this.current_call = {
                incident: null,
                identifier: null,
                type: null,
                message: null,
                date: null,
                location: null,
                coords: null,
                charname: null,
                phonenumber: null,
            }
            this.status = 'Available';
            $.post('http://drx_emsmdt/chooseStatus', JSON.stringify({
                status: 'Available'
            }))
        },


        // Database
        SearchDatabase(searchInput) {
            $.post('http://drx_emsmdt/searchDatabase', JSON.stringify({
                searchInput
            }))
        },
        SearchDatabaseClear() {
            this.searchInput = '';
            this.searchResults = {};
            this.selected_person = {
                identifier: null,
                firstname: null,
                lastname: null,
                phonenumber: null,
                database: {},
            };
        },
        SelectPerson(identifier, firstname, lastname, phone_number) {
            $.post('http://drx_emsmdt/fetchPersonDatabase', JSON.stringify({
                identifier,
                firstname,
                lastname,
                phonenumber: phone_number
            }))
            this.selected_person.identifier = identifier;
        },
        SubmitNewCase() {
            if (this.selected_person.identifier || this.new_case.title || this.new_case.desc) {
                $.post('http://drx_emsmdt/submitNewCase', JSON.stringify({
                    identifier: this.selected_person.identifier,
                    firstname: this.selected_person.firstname,
                    lastname: this.selected_person.lastname,
                    author: this.charname,
                    title: this.new_case.title,
                    desc: this.new_case.desc
                }))
                this.newcaseOverlay = false;
                this.new_case = {
                    title: null,
                    desc: null,
                }
            }
        },
        DeletePersonCase(id) {
            if (id) {
                $.post('http://drx_emsmdt/deletePersonCase', JSON.stringify({
                    identifier: this.selected_person.identifier,
                    id
                }))
            }
        },
        ViewCase(id, identifier, patientName, author, title, desc) {
            this.viewcaseOverlay = true;
            this.view_case = {
                id: id,
                identifier: identifier,
                patientName: patientName,
                author: author,
                title: title,
                desc: desc,
            };
        },
        SaveViewCase() {
            if (this.view_case.id) {
                $.post('http://drx_emsmdt/saveViewCase', JSON.stringify({
                    identifier: this.selected_person.identifier,
                    id: this.view_case.id,
                    title: this.view_case.title,
                    desc: this.view_case.desc
                }))
                this.viewcaseOverlay = false;
                this.view_case = {
                    id: null,
                    identifier: null,
                    patientName: null,
                    author: null,
                    title: null,
                    desc: null,
                };
            }
        },



        // Updates
        returnPersonDatabase(database, firstname, lastname, phonenumber) {
            this.selected_person.database = database;
            this.selected_person.firstname = firstname;
            this.selected_person.lastname = lastname;
            this.selected_person.phonenumber = phonenumber;
        },
    }
})

document.onreadystatechange = () => {
    if (document.readyState == 'complete') {
        window.addEventListener('message', (event) => {
            var drx = event.data;

            if (drx.open) {
                drx_emsmdt.openMenu(drx.charname, drx.status, drx.calls)
            }

            if (drx.close) {
                drx_emsmdt.closeMenu()
            }

            if (drx.update == 'updateCalls') {
                drx_emsmdt.calls = drx.calls
            }

            if (drx.update == 'returnDatabaseSearch') {
                drx_emsmdt.searchResults = drx.searchResults
            }

            if (drx.update == 'returnPersonDatabase') {
                drx_emsmdt.returnPersonDatabase(drx.database, drx.firstname, drx.lastname, drx.phonenumber)
            }

            if (drx.update == 'updatePersonDatabase') {
                drx_emsmdt.selected_person.database = drx.database
            }

            document.onkeyup = function(data) {
                if (data.which == 27) {
                    drx_emsmdt.closeMenu();
                }
            };
        });
    };
};