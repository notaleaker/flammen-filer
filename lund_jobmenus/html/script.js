
var job = 'unemployed';
var grade = 3;


$(document).keyup(function(e) {
    if (e.keyCode === 27) {

        $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

    }


});

function playClickSound() {
    var audio = document.getElementById("audio");
    audio.volume = 0.1;
    audio.play();
}

function openBossMenu(job, label, employees, fund, canwithdraw, candeposit, canhire, canrank, canfire, ranks) {

    currentRanks = ranks;
    currentBossMenuJob = job;
        
    var base = '<div class="clearfix" id="page"><!-- group -->'+
    
    '   <div class="clearfix grpelem slide-top" id="pu657"><!-- column -->';
    
    
    
base = base +'   <div class="gradient rounded-corners grpelem" id="u654"><!-- simple frame --></div>'+
'    <div class="colelem" id="u657"><!-- simple frame --></div>'+
'    <div class="clearfix colelem" id="u660-4"><!-- content -->'+
// '     <p>'+label.toUpperCase()+'</p>'+
'    </div>'+
'    <div class="clearfix colelem" id="u667-5"><!-- content -->'+
'     <p></p>'+
'    </div>'+
'    <div class="clearfix colelem" id="u667-4"><!-- content -->'+
'     <p>KONTI:  </p>'+
'    </div>'+
'    <div class="clearfix colelem" id="u663-4"><!-- content -->'+
'     ' +fund+ ',- DKK'
'    </div>'+
'    <div class="clearfix colelem" id="pu670-4"><!-- group -->';
if(canwithdraw) {
base = base +'     <button class="rounded-corners  grpelem ripple" onclick="openWithdraw()" id="u670-4"><!-- content -->'+
'      <p id="u670-2">INDSÆT PENGE</p>'+
'     </button>';
} else {
    base = base +'     <button class="rounded-corners  grpelem ripple" style="opacity: 0.5;" id="u670-4"><!-- content -->'+
'      <p id="u670-2">INDSÆT PENGE</p>'+
'     </button>';
}
if(candeposit) {
base = base +'     <button class="rounded-corners  grpelem ripple" onclick="openDeposit()" id="u673-4"><!-- content -->'+
'      <p id="u673-2">HÆV PENGE</p>'+
'     </button>';
} else {
    base = base +'     <button class="rounded-corners  grpelem ripple" style="opacity: 0.5;" id="u673-4"><!-- content -->'+
'      <p id="u673-2">HÆV PENGE</p>'+
'     </button>';
}

if(canhire) {
    base = base +'    <button id="addemployee" onclick="openHire(this)" class="u670-7"><!-- content -->'+
    '      <p id="u670-7">ANSÆT EN NY MEDARBEJDER</p>'+
    '     </button>';
} else {
    base = base +'   <button id="addemployee class="u670-7"><!-- content -->'+
    '      <p id="u670-7">ANSÆT EN NY MEDARBEJDER</p>'+
'     </button>';
}


base = base +'    </div>'+
'    <div class="clearfix colelem" id="u688-4"><!-- content -->'+
'     <p>Liste over ansatte</p>'+
'    <div class="colelem" id="u657-6"><!-- simple frame --></div>'+
'    <div class="clearfix colelem" id="u688-9"><!-- content -->'+
'    </div>'+
'    <div class="clearfix colelem" id="u682"><!-- column -->'+
'      <div class="clearfix grpelem" id="pu746-4"><!-- column -->'+
'       <div class="clearfix colelem" id="u645"><!-- content -->'+
'          <p>NAVN</p>'+
'       </div>'+
'       <div class="clearfix colelem" id="u649"><!-- content -->'+
'        <p>STILLINGER</p>'+
'       </div>'+
'       <div class="clearfix colelem" id="u642"><!-- content -->'+
'        <p>HANDLINGER</p>'+
'       </div>'+
'      </div>';



for (i = 0; i < employees.length; i++) {

base = base + '     <div class="rounded-corners clearfix colelem" id="u745"><!-- group -->'+
'      <div class="clearfix grpelem" id="pu746-4"><!-- column -->'+
'       <div class="clearfix colelem" id="u746-4"><!-- content -->'+
'        <span id="u746-4">'+employees[i].fullname+'</span>'+
'       </div>'+
'       <div class="clearfix colelem" id="u747-4"><!-- content -->'+
'        <p>'+employees[i].grade_label+'</p>'+
'       </div>'+
'      </div>';

if(canrank) {
    base = base +'     <button class="grpelem ripple  grpelem ripple" data-identifier="'+employees[i].identifier+'" onclick="openRanks(this)" id="u670-5"><!-- content -->'+
    '      <p id="u670-5">ÆNDRE</p>'+
    '     </button>';
}


if(canrank) {
    base = base +'     <button class="grpelem ripple" data-identifier="'+employees[i].identifier+'" onclick="sureWindow(this)" id="u670-6"><!-- content -->'+
    '      <p id="u670-6">FYR</p>'+
    '     </button>';
}



base = base +'     </div>';


}



base = base + '    </div>'+
'   </div>'+
'   <div class="verticalspacer" data-offset-top="0" data-content-above-spacer="712" data-content-below-spacer="18"></div>'+

'  </div>';
    



    $("#main_container").html(base);

        

}


function openHire() {

    playClickSound();


        var base = '<div id="input">' +


        '<div id="darken"><div>' +
        '<div id="inputfield" class="slide-top">' +
    
'        <p id="inputtext-3">ANSÆT NY</p>'+
'<input type="text" id="inputin-3" placeholder="ID, fx(134)"></input>' +
'    <button class="rounded-corners  grpelem ripple" onclick="promote(this)" id="inputtext-9"><!-- content -->'+
'      <p id="inputtext-9">Close</p>'+
'     <button class="rounded-corners  grpelem ripple" onclick="hireperson(this)" id="inputtext-6"><!-- content -->'+
'      <p id="inputtext-6">OK</p>'+
'     </button>'+
'     </button>'+

        '</div>';

        $("#pu657").append(base);


}



function openWithdraw() {

playClickSound();

        var base = '<div id="input">' +


        '<div id="darken"><div>' +
        '<div id="inputfield" class="slide-top">' +

'        <p id="inputtext">INDSÆT PENGE</p>'+
'<input type="text" id="inputin" placeholder="Sæt dine penge ind"></input>' + 
'     <button class="rounded-corners  grpelem ripple" onclick="depositAmount(this)" id="inputtex"><!-- content -->'+
'      <p id="inputtex">OK</p>'+
// '     </button>'+
'     <button class="rounded-corners  grpelem ripple" onclick="promote(this)" id="inputtext-12"><!-- content -->'+
    '      <p id="inputtext-12">Close</p>'+
    '     </button>'+
        
        '</div>' +
        '</div>';

        $("#pu657").append(base);


}

function openDeposit() {

    playClickSound();

    var base = '<div id="input">' +


    '<div id="darken"><div>' +
    '<div id="inputfield" class="slide-top">' +

'        <p id="inputtext">HÆV PENGE</p>'+
'<input type="text" id="inputin" placeholder="Hæv dine penge"></input>' + 
'     <button class="rounded-corners  grpelem ripple" onclick="withdrawAmount(this)" id="inputtex"><!-- content -->'+
'      <p id="inputtex">OK</p>'+
// '     </button>'+
'     <button class="rounded-corners  grpelem ripple" onclick="promote(this)" id="inputtext-12"><!-- content -->'+
'      <p id="inputtext-12">Close</p>'+
'     </button>'+
    
    '</div>' +
    '</div>';

    $("#pu657").append(base);

    }

function sureWindow(t) {

    playClickSound();


        var base = '<div id="input">' +

        '<div id="inputfield" class="slide-top">' +

'        <p id="inputtext">ARE YOU SURE?</p>'+
'        <p id="inputothertext">You want to fire ' +$(t).parent().find("#u746").text()+'</p>'+

'     <button class="rounded-corners " data-identifier="'+t.dataset.identifier+'" grpelem ripple" onclick="promote(this)" id="u673-5"><!-- content -->'+
'      <p id="inputtex-20">YES</p>'+
'     </button>'+
'     <button class="rounded-corners  grpelem ripple" onclick="promote(this)" id="inputtext-14"><!-- content -->'+
'      <p id="inputtext-14">NEJ</p>'+
'     </button>'+

        
        '</div>' +
        '</div>';

        $("#pu657").append(base);


}
function openRanks(t) {

    playClickSound();


        var base = '<div id="input">' +

        
        '<div id="darken"><div>' +
        '<div id="inputfield-2" class="slide-top">' +

'        <p id="inputtext">Vælg en ny stilling</p>'+
'      <div id="ranklist">';
for (i = 0; i < currentRanks.length; i++) {

base = base + '<div id="rankentry" data-identifier="'+t.dataset.identifier+'" data-grade="'+currentRanks[i].grade+'" onclick="promote(this)" class="ripple">'+currentRanks[i].grade_label.toUpperCase()+'</div>';
}

base = base +'</div>' +

        
        '</div>' +
        '</div>';

        $("#pu657").append(base);


}

function hireperson(t) {

    playClickSound();

        var id = $(t).parent().find('#inputin').val();
  
         $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

          $.post('https://lund_jobmenus/hire', JSON.stringify({job: currentBossMenuJob, id: id}));
}

function withdrawAmount(t) {

    playClickSound();

        var amount = $(t).parent().find('#inputin').val();

        $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

          $.post('https://lund_jobmenus/withdraw', JSON.stringify({job: currentBossMenuJob, amount: amount}));
}



function depositAmount(t) {

    playClickSound();

        var amount = $(t).parent().find('#inputin').val();

          $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

          $.post('https://lund_jobmenus/deposit', JSON.stringify({job: currentBossMenuJob, amount: amount}));
}

function fire(t) {

    playClickSound();

        var identifier = t.dataset.identifier;

       
         $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

          $.post('https://lund_jobmenus/fire', JSON.stringify({identifier: identifier, job: currentBossMenuJob}));


}

function promote(t) {

    playClickSound();

        var rank = t.dataset.grade;
        var identifier = t.dataset.identifier;
       
        $.post('https://lund_jobmenus/close', JSON.stringify({}));
        $("#main_container").fadeOut("slow", function() {

            $("#main_container").html("").fadeIn();
        });

          $.post('https://lund_jobmenus/setrank', JSON.stringify({identifier: identifier, rank: rank, job: currentBossMenuJob}));


}



window.addEventListener('message', function(event) {

    var edata = event.data;


    if (edata.type == "openBoss") {

        job = edata.job.job;
        grade = edata.job.grade;
       


           
       openBossMenu(edata.bossJob, edata.bossLabel, edata.employees, edata.fund, edata.perms.canWithdraw, edata.perms.canDeposit, edata.perms.canHire, edata.perms.canRank, edata.perms.canFire, edata.grades);


    }

    if (edata.type == "openCenter") {

        job = edata.job.job;
        grade = edata.job.grade;
        offduty = edata.offduty;

        const centerJobs = JSON.parse(edata.center);
      


        openJobCenter(centerJobs);




    }


    $(".addjob").click(function() {
        playClickSound();

        if ($(this).text().replace(/ /g, '') != 'SELECTED') {
            $(document).find(".addjob").text('SELECT');
            $(this).text('SELECTED');
            $.post('https://lund_jobmenus/addjob', JSON.stringify({
                job: this.dataset.job

            }));
        }

    });

   


});