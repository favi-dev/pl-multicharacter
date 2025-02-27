


var config = [];
var currentChar = null;
var nationalitys = [];
var playerCharacters = [];
var currentCidId = null;
var currentLocation = [];
var canDelete = false;
let ns = 0
$(document).ready(function () {
  function fetchData() {
    $.ajax({
      url: "https://countriesnow.space/api/v0.1/countries/",
      type: "GET",
      success: function (data) {
        const result = data.data;
        $.each(result, function (index, obj) {
          nationalitys.push(obj.country);
        });
      },
      error: function (error) {
        // // console.log("Error:", error);
      },
    });
  }
  fetchData();
  fetchCurrentChar = () => {
    if (playerCharacters.length > 0) {
      for (let i = 0; i < playerCharacters.length; i++) {
        if (playerCharacters[i].cid == currentCidId) {
          currentChar = playerCharacters[i];
        }
      }
    }
    return currentChar || null;
  };
  const loadLocale = (data) => {
    // // console.log(36, data);
    for (var key in data) {
      // // // console.log(key)
      var value = data[key];
      if (key.includes("label")) {
        $(`[for='${key.match(/\['for=(.*?)'\]/)[1]}']`).text(value);
      } else {
        // // console.log(value);
        $(`.${key}`).html(value);
      }
    }
  };
  const openSPAWNUI = (data, houses) => {
    $("body").slideDown(500);

    $(".character-slot-contain").slideUp(500);
    $(".spawn-ui-contain").slideDown(500);
    // // console.log("deleted");
    // $(".spawn-locations-list").empty();
  };

  $(document).on("click", "#spawn-play", function () {
    $.post(
      "https://qb-multicharacter/SpawnPed",
      JSON.stringify({
        location: currentLocation.id,
        type: currentLocation.type,
      })
    );
    $(".spawn-ui-contain").slideUp(500);
    $("body").slideUp(500);
  });

  setupLocations = (locations, houses, isNew) => {
    // // console.log("setu p loc");
    var tLocation = null;
    $(".spawn-locations-list").empty();
    for (let i = 0; i < locations.length; i++) {
      const location = locations[i];
      // // console.log("location", JSON.stringify(location))
      if (tLocation == null) {
        tLocation = {
          location : i + 1,
          type : location.lastLoc ? "current" : "location"
        };
      }
      let spawnLocationHtml = `
        <div class="spawn-location" data-location="${i + 1}" data-type="${location.lastLoc ? "current" : "location"}">
          <div class="spawn-loc-informations">
            <h1>${location.title}</h1>
            <p>${location.description}</p>
          </div>
          <img src="assets/devlet.png" alt="" />
        </div>
      `;

      if (location.lastLoc) {
        $(".spawn-locations-list").prepend(spawnLocationHtml);
      } else {
        $(".spawn-locations-list").append(spawnLocationHtml);
      }
    }
    for (let i = 0; i < houses.length; i++) {
      const houseData = houses[i];
      $(".spawn-locations-list").append(`
        <div class="spawn-location" data-location="${houseData.house}" data-type="house">
          <div class="spawn-loc-informations">
            <h1>House</h1>
            <p>${houseData.label}</p>
          </div>
          <img src="assets/house.png" alt="" />
        </div>
      `);
    }
    if (isNew) {
      $(".spawn-ui-contain").slideDown(500);
      $("body").slideDown(500);
    }
    // // console.log(JSON.stringify(tLocation))
    // // console.log(tLocation.id, tLocation.type, 1111)
    // $.post("https://qb-multicharacter/setCam", JSON.stringify({
    //   location: tLocation.location,
    //   type: tLocation.type
    // }))
  };
  $(document).on("click", ".spawn-location", function () {
    $(".spawn-location").each(function (k, v) {
      if ($(this).hasClass("active")) {
        $(this).removeClass("active");
      }
    });
    $(this).addClass("active");
    currentLocation.id = $(this).data("location");
    currentLocation.type = $(this).data("type");
    $.post(
      "https://qb-multicharacter/setCam",
      JSON.stringify({
        location: currentLocation.id,
        type: currentLocation.type,
      })
    );
  });
  setupAppartements = (appartements, isNew) => {
    // // console.log("setup appart");
    // // console.log(JSON.stringify(appartements));
    var tAppartment = null;
    $(".spawn-locations-list").empty();
    for (let i in appartements) {
      const appartement = appartements[i];
      if (tAppartment == null) {
        tAppartment = appartement;
      }
      // // console.log(appartement.name, appartement.label);
      $(".spawn-locations-list").append(`
        <div class="spawn-location" data-location="${appartement.name}" data-type="appartement">
          <div class="spawn-loc-informations">
            <h1>Appartement</h1>
            <p>${appartement.label}</p>
          </div>
          <img src="assets/house.png" alt="" />
        </div>
      `);
    }
    $.post("https://qb-multicharacter/setCam", JSON.stringify({
      location: tAppartment.name,
      type: "appartement"
    }))
  };

  window.addEventListener("message", function (event) {
    let luaData = event.data;
    if (luaData.action == "showCHARNUI") {
      config = luaData.configData;
      loadCharMenu(luaData);
    } else if (luaData.action === "hideUI") {
      noDisplayForNUI();
    } else if (luaData.action == "openSPAWNUI") {
      openSPAWNUI(luaData.data, luaData.houses);
    } else if (luaData.action == "loadLocale") {
      // // console.log(110, luaData.data);
      loadLocale(luaData.data);
    } else if (luaData.action == "setupLocations") {
      // // console.log(110, luaData.data);
      setupLocations(luaData.locations, luaData.houses, luaData.isNew);
    } else if (luaData.action == "setupAppartements") {
      // // console.log(110, luaData.data);
      setupAppartements(luaData.locations, luaData.isNew);
    }
  });
  const loadCharMenu = (data) => {
    playerCharacters = data.playerCharacters;
    $("body").slideDown(500);
    $(".character-slot-contain").show();
    $(".character-slot-contain").empty();
    var maksCharCount = config.MaxCharacters;
    var lockedSlots = config.LockedSlots;
    if (!data.delchar) {
      $("#delete-char").slideUp(100);
    }
    for (let i = 0; i < maksCharCount; i++) {
      var status =
        config.LockedSlotsIsPaid && lockedSlots.includes(i + 1)
          ? "none"
          : "available" || "available";
      // // console.log(status, 1111, lockedSlots.includes(i + 1));
      var personImg =
        status == "available" ? "assets/plus.png" : "assets/lock.png";
      $(".character-slot-contain").append(`
                <div class="char-slot" data-status="${status}" data-cid="${
        i + 1
      }">
                <img src="${personImg}" alt="inside-img">
            </div>`);
    }
    if (playerCharacters.length > 0 && playerCharacters !== null) {
      
      for (let i = 0; i < playerCharacters.length; i++) {
        // Corrected the loop condition
        let charData = playerCharacters[i];
        // if (i === 0) {
        //   $(`.char-slot[data-cid="${charData.cid}"]`).addClass("active");
        // }
        $(`.char-slot[data-cid="${charData.cid}"]`).html(`
          <img src="assets/${
            i === 0 ? "availableperson" : "availableperson"
          }.png" alt="">
        </div>`);
        $(`.char-slot[data-cid="${charData.cid}"]`).attr(
          "data-status",
          "created"
        );
      }
    }
    canDelete = data.delchar;
    currentCidId = 1;
    currentChar = fetchCurrentChar();
    const hasCharWithCidOne = playerCharacters.some((char) => char.cid === 1);
    // // console.log(hasCharWithCidOne, 1111, currentChar);
    if (hasCharWithCidOne) {
      $("#fuck").show();

      if (config.Framework == "qb") {
        $("#location").text(currentChar.charinfo.nationality);
      } else {
        $(".char-info-header.loc").text("Gender");
        $("#location").text(currentChar.sex == "1" ? "Female" : "Male");
      }
      //$("#location").text(currentChar.charinfo.nationality);
      $("#birthdate").text(currentChar.charinfo.birthdate);
      $("#job").text(currentChar.job.label);
      // $("#grade").text(currentChar.job.grade.name);
      $("#money").text(currentChar.money.cash +  "$");
      $("#name").text(currentChar.charinfo.firstname);
      $("#surname").text(currentChar.charinfo.lastname);
      // if
      // console.log("is",currentChar.charinfo.gender); 
      if (currentChar.charinfo.gender == 0 ) {


        $("#fucksex").text("Male");
        
      } else if (currentChar.charinfo.gender == 1) { $("#fucksex").text("Female");}

      $("#fuckbk").text(currentChar.money.bank + "$");
    
    } else {
      //Cid 1 active

    }
    var firstSlot = $(`.char-slot[data-cid="1"]`);
    var firstSlotStatus = firstSlot.data("status");
    if (firstSlotStatus == "created") {
      ns = ns + 1
      firstSlot.addClass("active");
      $(`.char-slot[data-cid="1"]`).html(`

        ${ns}
      </div>`);
    } else if (firstSlotStatus == "available") {
      $(`.char-slot[data-cid="1"]`).addClass("active");

      $(`.char-slot[data-cid="1"]`).css("border", "1px solid #c2c2c2");
      // $(".contcreatecharcter").show();
    }
    $.post(
      "https://qb-multicharacter/SetPedAction",
      JSON.stringify({
        
        data: currentChar,
      })
    );
  };

  //   playerCharacters = data.playerCharacters;
  // // //   //console.log(playerCharacters);
  //   $("body").slideDown(500);
  //   $(".character-slot-contain").empty();
  //   var maksCharCount = config.MaxCharacters;
  //   var lockedSlots = config.LockedSlots;
  //   for (let i = 0; i < maksCharCount; i++) {
  //     var status =
  //       config.LockedSlotsIsPaid && lockedSlots.includes(i + 1)
  //         ? "none"
  //         : "available" || "available";
  // // //         console.log(status, 1111, lockedSlots.includes(i + 1));
  //     var personImg =
  //       status == "available" ? "assets/plus.png" : "assets/lock.png";
  //     $(".character-slot-contain").append(`
  //               <div class="char-slot" data-status="${status}" data-cid="${
  //       i + 1
  //     }">
  //               <img src="${personImg}" alt="inside-img">
  //           </div>`);
  //   }
  //   if (data.playerCharacters.length > 0 && data.playerCharacters !== null) {
  //     data.playerCharacters.sort((a, b) => a.cid - b.cid);

  //     $("#fuck").slideDown(500);
  //     for (let i = 0; i < data.playerCharacters.length; i++) {
  //       let charData = data.playerCharacters[i];
  //       // İlk karakter için active class'ını ekle
  //       if (i === 0) {
  //         $(`.char-slot[data-cid="${charData.cid}"]`).addClass("active");
  //       }
  //       // Karakter slotunu güncelle
  //       $(`.char-slot[data-cid="${charData.cid}"]`).html(`
  //         <img src="assets/${i === 0 ? "person" : "availableperson"}.png" alt="">
  //       </div>`);
  //       $(`.char-slot[data-cid="${charData.cid}"]`).attr("data-status", "created");
  //     }
  //     if (!data.delchar) {
  //       $("#delete-char").slideUp(100);
  //     }
  //     currentCidId = 1;
  //     currentChar = fetchCurrentChar();

  // // //     console.log(currentChar);
  //     if (config.Framework == "qb") {
  //       $("#location").text(currentChar.charinfo.nationality);
  //     } else {
  //       $(".char-info-header.loc").text("Gender");
  //       $("#location").text(currentChar.sex == "1" ? "Female" : "Male");
  //     }
  //     //$("#location").text(currentChar.charinfo.nationality);
  //     $("#birthdate").text(currentChar.charinfo.birthdate);
  //     $("#job").text(currentChar.job.label);
  //     $("#grade").text(currentChar.job.grade.name);
  //     $("#money").text(currentChar.money.cash);
  //     $("#name").text(currentChar.charinfo.firstname);
  //     $("#surname").text(currentChar.charinfo.lastname);
  //     canDelete = data.delchar;
  //     $.post(
  //       "https://qb-multicharacter/SetPedAction",
  //       JSON.stringify({
  //         data: currentChar,
  //       })
  //     );
  //   } else if (data.playerCharacters.length == 0) {
  //     $(".contcreatecharcter").slideDown(500);
  //     $.post(
  //       "https://qb-multicharacter/SetPedAction",
  //       JSON.stringify({
  //         data: null,
  //       })
  //     );
  //   }
  // };
  $("#nation-context").click(function () {
    $(".context-menu").slideDown(500);
    $(".places-row").empty();
    for (var country in nationalitys) {
      var nationItem = `<div class="select-nation">${nationalitys[country]}</div>`;
      $(".places-row").append(nationItem);
    }
  });

  $("#search-inp").on("keyup", function () {
    var searchValue = $(this).val().toLowerCase();
    $(".select-nation").each(function () {
      var nationText = $(this).text().toLowerCase();
      if (nationText.indexOf(searchValue) > -1) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  });

  $(document).on("click", ".char-slot", function () {
    var cid = Number($(this).data("cid"));
    currentCidId = cid;
    currentChar = fetchCurrentChar();
    var status = $(this).attr("data-status");
    // console.log(status, 1111, currentChar);
    $(".char-slot").each(function (k, v) {
      if ($(this).hasClass("active")) {
        if ($(this).data("status") == "created") {
          ns = ns + 1 
          $(this).html(`
            <img src="assets/inputperson.png" alt="">
            </div>`);
            // // console.log(232232, $(this).data("status"))
        } else if (status == "available") {
          $(this).css("border", "1px solid rgba(249, 249, 249, 0.359)");
        }
        $(this).removeClass("active");
        // $(this).html(`
        //   <img src="assets/availableperson.png" alt="">
        //   </div>`);
      }
    });
    $(this).addClass("active");
    if (status != "available" && status != "none") {
      $(this).html(`
        1
        </div>`);
    }

    if (status == "available") {
      $(this).css("border", "1px solid #c2c2c2");
    }
    if (status == "created") {
      // $(`.char-slot[data-cid="${currentCidId}"]`).html(`
      //   <img src="assets/person.png" alt="">
      //   </div>`);
      $(".contcreatecharcter").slideUp(500, function () {
        $("#fuck").slideDown(500);
        if (config.Framework == "qb") {
          $("#location").text(currentChar.charinfo.nationality);
        } else {
          $(".char-info-header.loc").text("Gender");
          $("#location").text(currentChar.sex == "1" ? "Female" : "Male");
        }
        $("#birthdate").text(currentChar.charinfo.birthdate);
        $("#job").text(currentChar.job.label);
        $("#grade").text(currentChar.job.grade.name);
        $("#money").text(currentChar.money.cash);
        $("#name").text(currentChar.charinfo.firstname);
        $("#surname").text(currentChar.charinfo.lastname);
        $("#fucksex").text(currentChar.sex == "1" ? "Female" : "Male");

      });
      // // console.log(114, JSON.stringify(currentChar));
      $.post(
        "https://qb-multicharacter/SetPedAction",
        JSON.stringify({
          data: currentChar,
        })
      );
    } else if (status == "available") {
      // // console.log(114, JSON.stringify(currentChar));
      
      $("#fuck").slideUp(500, function () {
        $(".contcreatecharcter").slideDown(500);
        document.getElementById("imgintopcreate").style.top = "328px"
        document.getElementById("imgintopcreate").style.left = "77.5%"

        $(".character-slot-contain").slideUp(500)
      });

      $.post(
        "https://qb-multicharacter/SetPedAction",
        JSON.stringify({
          data: null,
        })
      );
    } else if (status == "none") {
      $(".tebex-integration").slideDown(500, function () {
        $("#fuck").slideUp(500);
      });
    }
  });
  $(document).on("click", "#play-game", function () {
    $.post(
      "https://qb-multicharacter/PlayGame",
      JSON.stringify({
        data: currentChar,
      }),
      function (res) {
        if (res) {
          $("body").slideUp(300);
          $("#fuck").slideUp(500);
          $(".character-slot-contain").slideUp(500);
          setTimeout(() => {
            $.post("https://qb-multicharacter/CloseUI", JSON.stringify({}));
          }, 10);
        }
      }
    );
  });

  $(document).on("click", ".cancel-delete", function () {
    $(".delete-confirmation").slideUp(500);
  });

  $(document).on("click", "#delete-char", function () {
    if (!canDelete) {
      // // console.log("You can't delete this character");
      return;
    }
    $(".delete-confirmation").slideDown(500);
  });

  $(document).on("click", ".confirm-delete", function () {
    $.post(
      "https://qb-multicharacter/DeleteCharacter",
      JSON.stringify({
        citizenid: currentChar.citizenid,
      }),
      function (res) {
        if (res) {
          $(".delete-confirmation").slideUp(500);
          $("#fuck").slideUp(500);
          $(".contcreatecharcter").slideDown(500);
          $(`.char-slot[data-cid="${currentCidId}"]`).html(`
                    <img src="assets/lock.png" alt="" style="width: 20px ;   border-radius: 50%;
  border: 1px solid rgba(240, 235, 235, 0.526);
background: #535151;
color: rgba(240, 235, 235, 0.526);">
                </div>`);
          $(`.char-slot[data-cid="${currentCidId}"]`).data("status", "available")
          // // console.log(1111, $(`.char-slot[data-cid="${currentCidId}"]`).data("status"))
          $(`.char-slot[data-cid="${currentCidId}"]`).removeClass("active");
          //BORDER 

          $(`.char-slot[data-cid="${currentCidId}"]`).css("border", "1px solid #c2c2c2");
          // background
          $(`.char-slot[data-cid="${currentCidId}"]`).css("background", "rgba(255, 255, 255, 0.061)");
          //remove from playercharacters table
          for (let i = 0; i < playerCharacters.length; i++) {
            if (playerCharacters[i].cid == currentCidId) {
              playerCharacters.splice(i, 1);
            }
          }
          // currentCidId = null;
          currentChar = null;
          $.post(
            "https://qb-multicharacter/SetPedAction",
            JSON.stringify({
              data: null,
            })
          );
        }
      }
    );
  });
  $(document).on("click", "#create-char", function () {
    var firstname = $("input[name='name']").val();
    var lastname = $("input[name='surname']").val();
    var birthdate = $("input[name='birthdate']").val();
    var nations = document.getElementById("Nationality").value //$("input[name='fuckNt']").val();
    // var height = $("input[name='height']").val();
    var nation = $("#nation-text").text();
    // // console.log(nation, 87);
    
    var gender = $(".gn[data-selected='true']").attr("data-type"); // $(".gn[data-selected='true']").attr("data-type");
    // let gen = document.getElementById("GetGender")

    // document.getElementById("female").onclick = () => {
    //   gen.innerHTML = "female";
    // }
    // document.getElementById("male").onclick = () => {
    //   gen.innerHTML = "male";  
    // }
    

    

    

    
    var currentCid = currentCidId;
    // // console.log(gender, 87);

    // // console.log(528,firstname, lastname, birthdate, height)
    // // console.log
    if (firstname == "" || lastname == "") {
      // // console.log("Please fill all fields");
      return
    } else if (gender == null) {
      // // console.log("Please select a gender");
      return;
    } else if (nations == "Nationality") {
      // // console.log("Please select a nationality");
      return;
    } else if (birthdate == "") {
      // // console.log("Please select a birthdate");
      return;
    } 
    // else if (height == 0 || height > 200 || height == "") {
    //   // // console.log("Please select a height");
    //   return;
    // }
    $(".contcreatecharcter").slideUp(500);
    $("body").slideUp(500);
    // // console.log(nation, 389);
    $.post(
      "https://qb-multicharacter/CreateCharacter",
      JSON.stringify({
        firstname: firstname,
        lastname: lastname,
        birthdate: birthdate,
        // height: height,
        nationality: nations,
        cid: currentCidId,
        gender: gender,
      })
    );
    // set default for inputs
    $("input[name='name']").val("");
    $("input[name='surname']").val("");
    $("input[name='birthdate']").val("");
    // $("input[name='height']").val("");
    $("#nation-text").text("Nationality");
    gen.innerHTML = ""
    $(".gn").each(function () {
      $(this).css("border", "none");
      
      $(this).attr("data-selected", "false");
    });
  });
  $(document).on("click", ".confirm-buying", function () {
    // // console.log("clicked 31");
    var inputValue = $("input[name='tebex-code']").val();
    if (inputValue == "") {
      // // console.log("Please enter a code");
      return;
    }
    $.post(
      "https://qb-multicharacter/CheckCode",
      JSON.stringify({
        code: inputValue,
        cid: currentCidId,
      }),
      function (res) {
        if (res) {
          $(".tebex-integration").slideUp(500, function () {
            
            $("#fuck").slideUp(500, function () {
              $(".contcreatecharcter").slideDown(500, function () {

                //$(`.char-slot[data-cid="${currentCidId}"]`).attr(
                //  "data-status",
                //  "available"
                //);
								// $(`.char-slot[data-cid="${currentCidId}"]`).data("status", "available")
                // // set img attr
                // $(`.char-slot[data-cid="${currentCidId}"]`).html(`
                //           <img src="assets/availableperson.png" alt="">
                //       </div>`);
                // //set active
                // $(`.char-slot[data-cid="${currentCidId}"]`).removeClass(
                //   "active"
                // );
                $(`.char-slot[data-cid="${currentCidId}"]`).attr("data-status", "available")
                // console.log(1111, $(`.char-slot[data-cid="${currentCidId}"]`).attr("data-status"));
                $(`.char-slot[data-cid="${currentCidId}"]`).find("img").attr("src", "assets/plus.png")
                $(`.char-slot[data-cid="${currentCidId}"]`).removeClass("active");
                //border
                $(`.char-slot[data-cid="${currentCidId}"]`).css("border", "1px solid #c2c2c2");
                // config.lockedslots remove
                config.LockedSlots = config.LockedSlots.filter(function (item) {
                  return item !== currentCidId;
                });
              });
            });
          });
          //creator open

          // set data-status
        } else {
          // // console.log("this code is invalid");
        }
      }
    );
  });
  $(document).on("click", ".gn", function () {
    // delete border from all class
    $(".gn").each(function () {
      $(this).css("border", "none");
      $(this).attr("data-selected", "false");
    });
    if ($(this).attr("data-type") == "female") {
      $(".gender").html("Female");
    } else {
      $(".gender").html("Male");
    }
    $(this).css("border", "1px solid #FFFFFF17");
    $(this).attr("data-selected", "true");
    $.post(
      "https://qb-multicharacter/ChangeGender",
      JSON.stringify({
        gender: $(this).attr("data-type"),
      }),
      function (res) {
        if (res) {
        } else {
          // // console.log("invalid selector");
        }
      }
    );
  });

  $(document).on("click", ".select-nation", function () {
    // reset other selected nation
    $(".select-nation").each(function () {
      $(this).html($(this).text());
      $(this).data("selected", "false");
    });
    var currentNation = $(this).text();
    $(this).html(
      `${currentNation} <img src="assets/selected.png" alt="" style="left: 0; top: 0; position: relative;">`
    );
    $(this).data("selected", "true");
    $(".location").text(currentNation);
    
    $(".context-menu").slideUp(500);
  });

  document.getElementById("return").onclick = ()=>{
    $("#contcreatecharcter").slideUp(0, ()=>{
      // $("#fuck").slideDown(0)  
        document.getElementById("imgintopcreate").style.top = "260px"
        document.getElementById("imgintopcreate").style.left = "51.5%"
      $(".character-slot-contain").slideDown(500)

    })

  }
  $(document).keydown(function (e) {
    if (e.keyCode == 27) {
      // visible check for context-menu
      if ($(".context-menu").is(":visible")) {
        $(".context-menu").slideUp(500);
      } else if ($(".tebex-integration").is(":visible")) {
        $(".tebex-integration").slideUp(500);
        // if currentChar is null, show contcreatecharcter else show main-contain
        //write code
        // if (currentChar == null) {
        //   $("#fuck").slideUp(300);
        //   $(".contcreatecharcter").slideDown(500);
        // } else {
        //   $(".contcreatecharcter").slideUp(500);
        //   $("#fuck").slideDown(500);
        // }
      }
    }
  });
  const noDisplayForNUI = () => {};
});


let sound = new Audio("https://r2.fivemanage.com/DhVNf9HgTMZNaIXJBW1vc/HoverOne.mp3");
sound.volume = 0.3;

function playSound(play) {
    if (play) {
        sound.currentTime = 0;
        sound.play();
    } else {
        sound.pause();
    }
}

$("button").hover(
    function () {
        playSound(true);
    }, 
    function () {
        playSound(false);
    }
);