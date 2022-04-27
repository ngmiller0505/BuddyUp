import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp()

//at 5:00am server time increment all dayNumber in pods
export const incrementDayTest = functions.pubsub.schedule("00 5 * * *").onRun(async (context) => {
    admin.firestore().collection("pods").get()
    .then(async querySnapshot => {
        const documents = querySnapshot.docs
        const pods = documents.map(doc => doc.data())
        pods.forEach(async pod => {
            const podID = pod.podID as string
            if (pod.dayNumber < pod.dayLimit) {
                let dayNumber =  pod.dayNumber as number
                dayNumber += 1
                pod.dayNumber = dayNumber
                admin.firestore().collection("pods").doc(podID).set(pod)
                .then(()=> {
                    console.log("Day successfully incremented for podID " + podID)
                })
                .catch( err => {
                    console.log("ERROR incrementing day for podID " + podID)
                    console.log(err)
                    
                })
                
            } else {
                console.log(podID + " is finished")
                await podFinished(pod)
            }

        }
    )})
    .catch( err => {
        console.log(err)
    })
})



//Input: pod
//copy pod data to finishedPods collection in firestore
async function createFinishedPod(pod : FirebaseFirestore.DocumentData) {
    const podID = pod.podID as string
    let dateCreated: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
    if (pod.hasOwnProperty('dateCreated')) {
        dateCreated = pod.dateCreated

    } else {
        let duration = pod.dayNumber
        let asDate = dateCreated.toDate()
        let newYear = asDate.getFullYear()
        let monthsSubtracted = Math.floor(duration / 30)
        
        let dayOfMonth = asDate.getDate()
        let newDay = Math.abs(dayOfMonth - duration)
        let newMonth = asDate.getMonth() - monthsSubtracted
        if (newMonth < 1) {
            newMonth = newMonth + 12
            newYear = newYear - 1
        }
        let newDate = new Date(newYear, newMonth, newDay, 0, 0 , 0, 0)

        dateCreated = admin.firestore.Timestamp.fromDate(newDate)

    }
    await admin.firestore().collection("finishedPods").doc(podID).create(
        {
            "communityOrFriendGroup": pod.communityOrFriendGroup,
            "memberAliasesAndIDs": pod.memberAliasesAndIDs,
            "memberAliasesAndTime": pod.memberAliasesAndTime,
            "memberAliasesAndReminderPhrase": pod.memberAliasesAndReminderPhrase,
            "memberAliasesAndLogPhrase": pod.memberAliasesAndLogPhrase,
            "memberAliasesAndSchedule": pod.memberAliasesAndSchedule,
            "memberAliasesAndScore": pod.memberAliasesAndScore,
            "memberAliasesAndColorCode": pod.memberAliasesAndColorCode,
            "memberAliasesAndName": pod.memberAliasesAndName,
            "podID": podID,
            "podName": pod.podName,
            "memberAliasesAndHasLogged" : pod.memberAliasesAndHasLogged,
            "invitedFriendIDs" : null,
            "dayNumber" : 0,
            "dayLimit" : pod.dayLimit,
            "memberAliasesAndSecondsFromGMT": pod.memberAliasesAndSecondsFromGMT,
            "memberAliasesAndHabitDays" : pod.memberAliasesAndHabitDays,
            "memberAliasesAndHabit" : pod.memberAliasesAndHabit,
            "memberAliasesAndSomethingNew" : pod.memberAliasesAndSomethingNew,
            "dateCreated": dateCreated
        }
    )


}
 


//Input: the pod that has finished
//add pod data to finishedPods collection in finishedPods
//remove podID from each user.podsApartOfID and add podID to user.finishedPodIDs
//send notification to members of pod saying that "you've finished"
async function podFinished(pod: FirebaseFirestore.DocumentData) {

    const aliases = ["a", "b", "c"]
    const memberIDs = pod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
    const podID = pod.podID as string

    createFinishedPod(pod)
    .then(() =>{
        console.log("Created finished Pod for podID " + podID + " and STARTING TO REMOVE EACH PERSON FROM GROUP AND SEND FINISHED NOTIFICATION")
        aliases.forEach(async alias => {
            if (!(memberIDs[alias] === undefined ||  memberIDs[alias] === null)) {
                const memberID = memberIDs[alias] as string
    
                removePersonFromPod(pod, alias, memberID)
                .then(() => {
                    console.log("PERSON REMOVED FROM POD BECAUSE POD IS OVER")
                })
                .catch((error) => {
                    console.log(error)
                    
                })  
                
    
                const user = await getUser(memberID) as FirebaseFirestore.DocumentData
                let podsApartOfID = user.podsApartOfID as string[]
                podsApartOfID = podsApartOfID.filter(ID => ID !== podID)
                user.podsApartOfID = podsApartOfID
                const finishedPodsIDs = user.finishedPodIDs as string[]
                finishedPodsIDs.push(podID)
                user.finishedPodIDs = finishedPodsIDs
    
    
            
                admin.firestore().collection("users").doc(memberID).set(user)
                .then(() => {
                    console.log(memberID + " SUCCESFULLY REMOVED FROM POD BECAUSE POD IS OVER")
                })
                .catch((error) => {
                    console.log(error)
                    
                })  
                
    
                await sendFinishedNotification(pod, memberID)
                
            }
            
        });
    })
    .catch((err) => {
        console.log(err)
    })


}


async function sendFinishedNotification(pod: FirebaseFirestore.DocumentData, UID: string) {
    const user = await getUser(UID) as FirebaseFirestore.DocumentData
    
    const tokenArray = user.token as string[]

    // if (token !== "Logged Out") {
        const dayLimit = pod.dayLimit as number

        const podMemberHabits = pod.memberAliasesAndHabit as FirebaseFirestore.DocumentData
        const podMemberIDs = pod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
        const aliases = ["a", "b", "c"]
        let habit = "habit"
        aliases.forEach(alias => {
            if (podMemberIDs[alias] === UID) {
                habit = podMemberHabits[alias]
            }
        });
        // const message = {
        //     notification: {
        //         title: "Congratulations!",
        //         body: "You've completed your " + dayLimit.toString() + " day " + habit + " commitment!",
        //     },
        //     token: token,
        // }
        let title = "Congratulations!"
        let body = "You've completed your " + dayLimit.toString() + " day " + habit + " commitment!"
        let category = ""
        sendNotification(title, body, category, "", tokenArray)
        // const response = await admin.messaging().send(message)

        // console.log("POD FINISHED NOTIFICATION RESPONSE: ", response)
    // }
}


//when friend request is accepted, send notification to the person that sent the friend request
export const onFriendRequestAccepted = functions.https.onCall(async (data, context) => {
    const friendID = data.friendID as string
    const userID = data.userID as string
    const friendUser = await getUser(friendID) as FirebaseFirestore.DocumentData
    const user = await getUser(userID) as FirebaseFirestore.DocumentData
    await sendFriendRequestAcceptedNotification(friendUser, user)

    
})



async function sendFriendRequestAcceptedNotification(friendUser: FirebaseFirestore.DocumentData, user: FirebaseFirestore.DocumentData) {
    console.log("FRIEND REQUEST ACCEPTED NOTIFICATION TRIGGERED")
    const userFirstName = user.firstName as string
    const friendTokenArray = friendUser.token as string[]
    // if (friendToken !== "Logged Out") {
        // const message = {
        //     notification: {
        //         title: userFirstName + " accepted your friend request!",
        //         body: "Tap to form a habit group with them.",
        //     },
        //     apns: {
        //         payload: {
        //         aps: {
        //             category: "Profile Info",
        //             badge: 1
        //         }
        //         },
        //     },
        //     token: friendToken,
        // }
        const title = userFirstName + " accepted your friend request!"
        const body = "Tap to form a habit group with them."
        const category = "Profile Info"
        const podID = ""
        sendNotification(title, body, category, podID, friendTokenArray)
        // const response = await admin.messaging().send(message)
        // console.log("FRIEND REQUEST ACCEPTED message notification", response)
    // }
}


//when friendRequest is sent, send notification to other friend
export const onFriendRequestSent = functions.https.onCall(async (data, context) =>  {
    console.log("FRIEND REQUEST SENT NOTIFICATION TRIGGERED")

    //TODO: MAKE SURE RECIEVER HASNT BLOCKED SENDER


    const senderID = data.senderID as string
    const recieverID = data.recieverID as string
    const senderUser = await getUser(senderID) as FirebaseFirestore.DocumentData
    const recieverUser = await getUser(recieverID) as FirebaseFirestore.DocumentData
    await sendFriendRequestNotification(senderUser, recieverUser)

})



//when message is sent, send notifications to group members, set somethingNew = true for other group members
export const onMessageSend = functions.https.onCall(async (data, context) => {
    console.log("MESSAGE RECIEVED NOTIFICATION TRIGGERED")


    const senderID = data.senderID as string
    const senderAlias = data.senderAlias as string
    const podID = data.podID as string
    const messageText = data.messageText as string
    const messageType = data.messageType as string
    const senderUser = await getUser(senderID) as FirebaseFirestore.DocumentData



    console.log("senderID: ", senderID)
    console.log("senderAlias: ", senderAlias)
    console.log("podID: ", podID)
    console.log("messageText: ", messageText)
    console.log("messageType: ", messageType)
    const pod = await getPod(podID) as FirebaseFirestore.DocumentData
    
    //TODO, instead of get pod and get user, we can retrieve this info from data
    const memberIDsDict = pod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
    const aliases = Object.keys(memberIDsDict)
    const otherAliases = aliases.filter(alias => (alias !== senderAlias))
    // const promises : Promise<void>[] = [] 
    otherAliases.forEach(async otherAlias => {
        console.log("alias:", otherAlias)
        const recieverID = memberIDsDict[otherAlias] as string
        console.log("memberIDsDict[alias] = ", recieverID)
        
        const recieverUser = await getUser(recieverID) as FirebaseFirestore.DocumentData
        sendMessageRecievedNotification(senderUser, recieverUser, pod, messageText, messageType)
        .then(() => console.log("MESSAGE SENT SUCCESSFULLsY"))
        .catch(err => console.log(err))

        somethingNewInPodForUser(podID, otherAlias)


        
    })
    // if (promises.length != 0) {
    //     Promise.all(promises)
    //     .then(result => console.log(result))
    //     .catch(err => console.log(err))
    // } else {
    //     console.log("THIS IS A POD WITH NO OTHER MEMBERS SO NO MESSAGE NOTIFICATIONS OR somethingNew = true TO SEND")
    // }


    //TODO MAKE SURE SENDER HASN'T BANNED THIS TYPE OF NOTIFICATION

})



//onHabit Logged set somethingNew = true for other members of group
export const onHabitLogged = functions.https.onCall(async (data, context) => {

    const podID = data.podID as string
    const alias = data.alias as string
    console.log("onHabitLogged podID and alias: ", podID, alias)
    const aliases = ["a", "b", "c"]
    const friendAliases = aliases.filter(a => (a !== alias))
    // const promises = []
    const pod = await getPod(podID) as FirebaseFirestore.DocumentData
    for (const friendAlias of friendAliases) {
        if (pod.memberAliasesAndIDs[alias] !== null || pod.memberAliasesAndIDs[alias] !== undefined) {
            somethingNewInPodForUser(podID, friendAlias)
        }
    }
    // if (promises.length !== 0) {
    //     Promise.all(promises)
    //     .then(result => console.log(result))
    //     .catch(err => console.log(err))
    // } else {
    //     console.log("THIS IS A POD WITH NO OTHER MEMBERS SO NO MESSAGE NOTIFICATIONS OR somethingNew = true TO SEND")
    // }

})



//Every 5 minutes we fetch all pod data from podCollection in firestore
//We check habit times for all members of all pods. If habit time is now see "PATH A". If habit time is 12 hours away see "PATH B"
//PATH A: 
//      1)for all pods that have habit time right now, makes sure that today is a scheduled habit day and return [alias, podID] tuple
//          a)sets habitDay += 1 for user (this is used as denominator for calculating habit compconsted percentage score)
//      2)find device tokens for all primary users and return [alias, podID, token] tuple
//      3) call sendPrimaryHabitReminder which will
//          a)send notification to remind user to do habit
//          b)find tokens for user's group members and send them notifications to remind them to keep their friend accountable
//          c)send missingVerify to messages collection in Firestore
//              i)this sets somethingNew = true for all
//PATH B: 
//      1) reset hasLogged = false, which in the future will unlock the Log Habit button on the front end
//FRIEND JOIN REMINDER NOTIFICATION: 
//  1) Find groups that have a member that hasn't joined yet and see if it is time to send a reminder notification
export const habitReminderNotificationSchedule = functions.pubsub.schedule("*/5 * * * *").onRun(async (context) => {
    
    const pods = await getAllPods() as FirebaseFirestore.DocumentData[]
    const today = new Date()
    const minutes = today.getMinutes()
    const hours = today.getHours()
    const timeAsFourDigitNum = hours * 100 + minutes


    //sort pods in PATH A and PATH B
    const [podsToSendNotisTo, podsToResetHasLogged] = sortPods(pods, timeAsFourDigitNum)

    //PATH A
    console.log("HEADED INTO findPodsWithSameHabitTimeAsNow")
    console.log("HEADED INTO makeSureDayItsAnOnDay")
    const adjustedAliasAndPodIDToSendNotisTo = makeSureItsAnOnDay(podsToSendNotisTo, pods)//returns [["a", DUMMYPODID]]
  
    sendPrimaryHabitReminder(adjustedAliasAndPodIDToSendNotisTo, pods)


    //PATH B
    setHabitLoggedReset(podsToResetHasLogged, pods)


    //INDEPENDENT
    checkIfFriendNeedsReminderGroup(pods)


  });



function checkIfFriendNeedsReminderGroup(listOfPods: FirebaseFirestore.DocumentData[]) {
    listOfPods.forEach(pod => {
        if (pod.invitedFriendIDs == null){
            return
        } 
       let invitedFriendIDs = pod.invitedFriendIDs as string[]
        if (invitedFriendIDs.length == 0) {
            return
        }
        let dateCreated = pod.dateCreated.toDate() as Date
        let now = admin.firestore.Timestamp.now().toDate() as Date
        let millisecondDifference = now.valueOf() - dateCreated.valueOf()
        let twentyFourHours = 3600000 * 24
        let fiveMinutes = 3600000 / 12
        if (millisecondDifference > twentyFourHours){
            //console.log("app " + remainingApp.appID + " is old. Adding to leftovers")

           if (millisecondDifference % twentyFourHours < fiveMinutes) {
                invitedFriendIDs.forEach(async friendID => {
                    const title = "Friend Invite Reminder"
                    const inviterName = pod.memberAliasesAndName["a"]
                    const body = inviterName + " invited you to join their habit group!"
                    const category = "chat"
                    const podID = ""
                    const friend = await getUser(friendID) as FirebaseFirestore.DocumentData
                    const tokenArray = friend.tokenArray as string[]
    
                
                    
    
                    sendNotification(title, body, category, podID, tokenArray)
                });

           }
            
        }        
    })
}


//takes the serverTime and uses the recorded timezone to determine whether it is
//time for a user to do his habit (PATH A) OR time to reset hasLogged (PATH B)
//returns an array of tuples [alias, podID] for users who have their scheduled habit coming up
  function sortPods(listOfPods : FirebaseFirestore.DocumentData[], serverTimeAsFourDigitNum: number) : [string[][], string[][]]  {
    const podsToReset : string [][] = []
    const podsToASendNotisTo : string[][] = []


    listOfPods.forEach(pod => {
        const memberTimeDict = pod.memberAliasesAndTime as FirebaseFirestore.DocumentData
        let memberSecondsFromGMTDict = pod.memberAliasesAndSecondsFromGMT as FirebaseFirestore.DocumentData

        Object.keys(memberTimeDict).forEach(alias => {
            const time = memberTimeDict[alias] as number
            const secondsFromGMT = memberSecondsFromGMTDict[alias] as number

            if (secondsFromGMT == undefined) {
                return
            }
            const convertedTime = convertLocalTimeHabitToGMTTime(time, secondsFromGMT)

            const rightTimeToReset = (Math.abs(convertedTime - serverTimeAsFourDigitNum) > 1155 && Math.abs(convertedTime - serverTimeAsFourDigitNum) < 1201)
            const rightTimeToSendNotisTo = ((convertedTime - serverTimeAsFourDigitNum > -1  &&  convertedTime - serverTimeAsFourDigitNum < 5) && (pod.memberAliasesAndHasLogged[alias] === false))
            if (rightTimeToReset) {
                podsToReset.push([alias, pod.podID])
            } else if (rightTimeToSendNotisTo) {
                podsToASendNotisTo.push([alias, pod.podID])
            } 
        })         

        });

    return [podsToASendNotisTo, podsToReset]

  }

  //Input: podID, userID, alias
  //determines whether missingVerify message needs newDay banner in display
  //sends missingVerify message to messages collection in firestore for pod
  //adds something new for all members of pod
  async function sendMissingVerify(podID: string, userID: string, alias: string) {
    const messageID = uuidv4()
    const timestamp = admin.firestore.Timestamp.now()
    const isNewDay = await decideWhetherMissingMessageIsNewDay(podID, timestamp) 
    // const pod = getPod(podID) as FirebaseFirestore.DocumentData
    admin.firestore().collection("messages").doc(podID).collection(podID).doc(messageID).set({
        "id" : timestamp,
        "newDay" : isNewDay, //TODO: check if its actually a new day
        "senderID": userID,
        "text": "",
        "type": "Missing Verify",
        "messageID": messageID
   
    })
    .then(async () => {
        console.log("Added Missing Verify for element: :", [podID, alias])
        // const aliases = ["a", "b", "c"]
        // const friendAliases = aliases.filter(a => a !== alias)
        // const promises = []
        // for (const friendAlias of friendAliases) {
        //     if (pod.memberAliasesAndIDs[friendAlias] !== null || pod.memberAliasesAndIDs[friendAlias] !== undefined) {
        //         console.log("Adding somethingNew = true for (podID, friendAlias) = ",  [podID, friendAlias])
        //         somethingNewInPodForUser(podID, friendAlias)
        //     }
        // }
        // if (promises.length !== 0) {
        //     Promise.all(promises)
        //     .then(result => console.log(result))
        //     .catch(err => console.log(err))
        // } else {
        //     console.log("THIS IS A POD WITH NO OTHER MEMBERS SO NO MESSAGE NOTIFICATIONS OR somethingNew = true TO SEND")
        // }
    })
    .catch( err => {
        console.log(err)
    })
  }



//Input: podID, userID 
//compares last new day message and sees if it was today, if not, add new day message
async function decideWhetherMissingMessageIsNewDay(podID: string, missingVerifyTimestamp: FirebaseFirestore.Timestamp) : Promise<boolean> {
    //TODO need to tell whether there is new day on local server or if this missing message needs to be a newday
    return admin.firestore().collection("messages").doc(podID).collection(podID).orderBy("id", "desc").get()
    .then(async querySnapshot => {
        const documents = querySnapshot.docs
        const messages = documents.map(doc => doc.data())
        const newDayMessages = messages.filter(message => message.newDay === true)

        if (newDayMessages.length === 0) {
            return true
        }
        const latestNewDayMessage = newDayMessages[0]
        const lastNewDayMessageTimestamp = latestNewDayMessage.id as FirebaseFirestore.Timestamp
        const latestNewDayDate = lastNewDayMessageTimestamp.toDate().getUTCDate()
        const missingVerifyTimestampDate = missingVerifyTimestamp.toDate().getUTCDate()
        console.log("IN decideWhetherMissingMessageIsNewDay [decideWhetherMissingMessageIsNewDay, missingVerifyTimestampDate] = ", [latestNewDayDate, missingVerifyTimestampDate])
        if (latestNewDayDate === missingVerifyTimestampDate) {
            return false
        } else {
            return true
        }
        
    })
    .catch( err => {
        console.log(err)
        return false
    })
    
}


//Input: [alias, podID] where the habit is expected to be logged in 12 hours away 
//set hasLogged = false to allow person to log habit
function setHabitLoggedReset(podsToResetHasLogged: string[][], listOfPods: FirebaseFirestore.DocumentData[]) {
    podsToResetHasLogged.forEach(element => {
        
        console.log("About to reset hasLogged for [alias, podID] = ", element)


        const elementAlias = element[0]
        const elementPodID = element[1]
        const currentPodList = listOfPods.filter(pod => (pod.podID === elementPodID))
        console.log("AFTER FILTER to find pod data to reset hasLogged currentPodList.length = ", currentPodList.length)
        const currentPod = currentPodList[0]
        const memberHasLogged = currentPod.memberAliasesAndHasLogged as FirebaseFirestore.DocumentData
        memberHasLogged[elementAlias] = false
        admin.firestore().collection("pods").doc(elementPodID).update({
            memberAliasesAndHasLogged : memberHasLogged
        })
        .then(() => {
            console.log("for "+ currentPod.podID +" memberAliasesAndHasLogged[" + elementAlias +"] set to false")
        })
        .catch( err => {
            console.log(err)
        })

    })
}

// function findPodsToResetHasLogged(serverTimeAsFourDigitNum: number, listOfPods: FirebaseFirestore.DocumentData[]) : string[][] {
//     const podsToReset : string [][] = []

//     listOfPods.forEach(pod => {
//         const memberTimeDict = pod.memberAliasesAndTime as FirebaseFirestore.DocumentData
//         const memberSecondsFromGMTDict = pod.memberAliasesAndSecondsFromGMT as FirebaseFirestore.DocumentData

//         Object.keys(memberTimeDict).forEach(element => {
//             const time = memberTimeDict[element] as number
//             const secondsFromGMT = memberSecondsFromGMTDict[element] as number
//             const convertedTime = convertLocalTimeHabitToGMTTime(time, secondsFromGMT)

//             const rightTimeToReset = (Math.abs(convertedTime - serverTimeAsFourDigitNum) > 1155 && Math.abs(convertedTime - serverTimeAsFourDigitNum) < 1201)

//             if (rightTimeToReset) {
//                 podsToReset.push([element, pod.podID])
//             }    
//         })         

//         });
//         console.log("RETURNING FROM findPodsToResetHasLogged with podsToReset = ", podsToReset)
//         return podsToReset
// }

//Input: friendAlias that has a habit time for right now
//sends notifications to other members of group
function sendFriendHabitReminder(currentPod: FirebaseFirestore.DocumentData, friendAlias: string) {

    //TODO: MAKE SURE USER HASN'T BANNED THIS TYPE OF NOTIFICATION
    const podID = currentPod.podID as string
    const memberIDsDict = currentPod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
    const memberAliasesAndName = currentPod.memberAliasesAndName as FirebaseFirestore.DocumentData
    const friendFirstName = memberAliasesAndName[friendAlias] as string
    const aliases = Object.keys(memberIDsDict) 
    const otherAliases = aliases.filter(alias => (alias !== friendAlias))
    console.log("SENDING TO OTHER MEMBERS OF GROUP [primaryAlias, otherAliases, podID] = ", [friendAlias, otherAliases, podID])
    const memberHabitDict = currentPod.memberAliasesAndHabit as FirebaseFirestore.DocumentData
    const friendHabit = memberHabitDict[friendAlias] as string 
    
    otherAliases.forEach(async alias => {

        console.log("in FOR loop, [friendFirstName, FriendHabit] = ", [friendFirstName, friendHabit])
        const UID = memberIDsDict[alias] as string
        //console.log("memberIDsDict[alias] = ", UID)
        const user = await getUser(UID) as FirebaseFirestore.DocumentData
        const tokenArray = user.token as string[]
        // if (token !== "Logged out") {

            // const message = {
            //     notification: {
            //         title: "Groupmate reminder!",
            //         body: "Help make sure " + friendFirstName + " keeps their " + friendHabit + " commitment",
            //     },
            //     apns: {
            //         payload: {
            //           aps: {
            //             category: "chat",
            //             badge: 1
        
            //           }
            //         },
            //       },
            //       data: {
            //         podID: podID
            //     },
            //     token: token,
            // }
            const title = "Groupmate reminder!"
            const body = "Help make sure " + friendFirstName + " keeps their " + friendHabit + " commitment"
            const category = "chat"
            sendNotification(title, body, category, podID, tokenArray)

            // admin.messaging().send(message)
            // .then(() => {
            //     console.log("SENT FRIEND HABIT REMINDER FOR ELEMENT: ", [podID, alias])
            // })
            // .catch((error) => {
            //     console.log(error)
            // })
           
        // } else {
        //     console.log("FRIEND USER LOGGED OUT NO NOTIFICATION SENT: ", [podID, alias])
        // }
    })

}

//Input: podID, alias
//If somethingNew = true, there will be white dot and pulsing arrow on podRow display
//This function sets somethingNew = true for alias in podID
function somethingNewInPodForUser(podID: string, alias: string) {

    if (alias === "a") {
        admin.firestore().collection("pods").doc(podID).update({
            "memberAliasesAndSomethingNew.a" : true
        })
        .then(() => {
            console.log("Added something new = true for alias " + alias + " in podID " + podID)
        })
        .catch( err => {
            console.log(err)
        })
    } 
    else if (alias === "b") {
        admin.firestore().collection("pods").doc(podID).update({
            "memberAliasesAndSomethingNew.b" : true
        })
        .then(() => {
            console.log("Added something new = true for alias " + alias + " in podID " + podID)
        })
        .catch( err => {
            console.log(err)
        })
    }
    else if (alias === "c") {
        admin.firestore().collection("pods").doc(podID).update({
            "memberAliasesAndSomethingNew.c" : true
        })
        .then(() => {
            console.log("Added something new = true for alias " + alias + " in podID " + podID)
        })
        .catch( err => {
            console.log(err)
        })
    }
}



function addBuddyUpBotWelcomeMessage(pod: FirebaseFirestore.DocumentData) {
    const podID = pod.podID as string
    const messageID = uuidv4()
    const communityOrFriendGroup = pod.communityOrFriendGroup as string
    const invitedFriendIDs = pod.invitedFriendIDs
    let message: string
    if (communityOrFriendGroup === "Friend") {
        if (invitedFriendIDs === null || invitedFriendIDs.length < 1 || invitedFriendIDs === undefined) {

            message = "Welcome to your new habit group. For the next 30 days, you will stick to the commitment you've made in an effort to build a habit.\n\n" +
            "You can tap the INFO button in the upper right of your screen to view your commitment.\n\n" +
            "No pressure, but as a solo you've chosen the hardest habit-building road. You've got no one to keep you accountable except yourself.\n\nGood Luck!"
        } else {
            message = "Welcome to your new habit group. For the next 30 days, you and your friends will stick to the commitments you've made in an effort to build habits and keep each other accountable.\n\n" +
            "You can tap the INFO button in the upper right of your screen to view your group's commitments.\n\n" + 
            "Feel free to trash talk your friends and place bets about who's going to end up with lowest score. Or you can be nice and friendly.\n\nGood Luck!"
        }

    } else {
        message = "Welcome to your new habit group. For the next 30 days, you and your group will stick to the commitments you've made in an effort to build a habit.\n\n" +
        "You can tap the INFO button in the upper right of your screen to view your group's commitments.\n\n" + 
        "Feel free to introduce yourself and chat with your groupmates.\n\nGood Luck!"
    }
    admin.firestore().collection("messages").doc(podID).collection(podID).doc(messageID).set({
        "id" : admin.firestore.Timestamp.now(),
        "newDay" : true,
        "senderID": "BuddyUp Bot",
        "text": message, //TODO: WRITE GOOD BUDDY UP MESSAGE
        "type": "bot intro",
        "messageID" : messageID
   
    })
    .then(() => {
        console.log("ADDED IN BUDDYUP BOT WELCOME MESSAGE")
    })
    .catch( err => {
        console.log(err)
    })
}






async function sendMessageRecievedNotification(senderUser: FirebaseFirestore.DocumentData, recieverUser: FirebaseFirestore.DocumentData, pod: FirebaseFirestore.DocumentData, messageText: string, messageType: string) {
    console.log("IN sendMessageRecievedNotification")


    const tokenArray = recieverUser.token as string[]
    const senderFirstName = senderUser.firstName as string
    const podID = pod.podID as string
    // if (token !== "Logged Out") { 
    if (messageType === "chat")  {
        // const message = {
        //     notification: {
        //         title: senderFirstName,
        //         body: messageText,
                
        //     },
        //     apns: {
        //         payload: {
        //           aps: {
        //             category: "chat",
        //             badge: 1
        //           }
        //         }
        //       },

        //     data: {
        //         podID: podID,
        //     },
           
        //     token: token,
        // }
        // console.log("message: ", message)
        const title = senderFirstName
        const body = messageText
        const category = "chat"
        console.log("about to send message notification")
        sendNotification(title, body, category, podID, tokenArray)
        
        // const response = await admin.messaging().send(message)
        // console.log("Message Recieved message: ", response)
    
    } else {
        // const message = {
        //     notification: {
        //         title: senderFirstName + " logged their habit",
        //         body: messageText,

        //     },
        //     apns: {
        //         payload: {
        //           aps: {
        //             category: "chat",
        //             badge: 1
    
        //           }
        //         },
                
        //       },

        //       data: {
        //         podID: podID
        //     },
            
        //     token: token,
        // }
        const title = senderFirstName + " logged their habit"
        const body = messageText
        const category = "chat"
        console.log("about to send habit Log notification")
        sendNotification(title, body, category, podID, tokenArray)
        // console.log("message: ", message)

        // const response = await admin.messaging().send(message)
        

        // console.log("Message Recieved message: ", response)
    
    }
// } else {
//     console.log("USER LOGGED OUT, NO CHAT NOTIFICATION SENT")
// }


}


async function sendFriendRequestNotification(senderUser: FirebaseFirestore.DocumentData, recieverUser: FirebaseFirestore.DocumentData) {
    const senderFirstName = senderUser.firstName as string
    const recieverTokenArray = recieverUser.token as string[]
    // if (recieverToken !== "Logged Out") {
    // const message = {
    //     notification: {
    //         title: "Friend Request",
    //         body: senderFirstName + " sent you a friend request. Tap to respond.",

    //     },
    //     apns: {
    //         payload: {
    //           aps: {
    //             category: "Profile Info",
    //             badge: 1

    //           }
    //         }
    //       },
    //     token: recieverToken,
    // }
    const title = "Friend Request"
    const body = senderFirstName + " sent you a friend request. Tap to respond."
    const category = "Profile Info"
    sendNotification(title, body, category, "", recieverTokenArray)
    // const response = await admin.messaging().send(message) 
    // console.log("Send Friend Request message response: ", response)
    // } else {
    //    console.log("USER LOGGED OUT, NO NOTIFICATION SENT") 
    // }

}










async function sendFriendPodRequestNotification(senderUser: FirebaseFirestore.DocumentData, recieverUser: FirebaseFirestore.DocumentData, friendPod: FirebaseFirestore.DocumentData) {
    

    const senderFirstName = senderUser.firstName as string
    const senderLastName = senderUser.lastName as string
    const tokenArray = recieverUser.token as string[]

    // if (token !== "Logged Out") {

    const podID = friendPod.podID as string

    // const message = {
    //     notification: {
    //         title: "Friend Habit Group Invite",
    //         body: senderFirstName + " " + senderLastName + " wants to start a habit group group with you.",
    //     },
    //     apns: {
    //         payload: {
    //           aps: {
    //             category: "chat",
    //             badge: 1
    //           }
    //         },            
    //       },
    //       data: {
    //         podID: podID
    //     },
    //     token: token,

    // }
    // const response = await admin.messaging().send(message)
    // console.log("Community Pod Created messaging response: ", response)
// } else {
//     console.log("USER LOGGED OUT NO NOTIFICATION SENT")
// }

    const title = "Friend Habit Group Invite"
    const body = senderFirstName + " " + senderLastName + " wants to start a habit group group with you."
    const category = "chat"
    sendNotification(title, body, category, podID, tokenArray)

}





async function sendCommunityPodCreatedNotification(users: FirebaseFirestore.DocumentData[], pod: FirebaseFirestore.DocumentData) {

    const userNames = users.map(user => user.firstName)
    users.forEach(async user => {
            const tokenArray = user.token as string[]
        // if (token !== "Logged Out") {
            const currentFirstName = user.firstName
            const otherUserName = userNames.filter(userName => (userName !== currentFirstName))
            const podID = pod.podID as string
            const habit = pod.habit 
            let catagoryOrSubcatagory = ""
            if (habit === null) {
                catagoryOrSubcatagory = "habit"
            } else {
                catagoryOrSubcatagory = habit
            }
            
            // const message = {
            //     notification: {
            //         title: "Your " + catagoryOrSubcatagory + " group has been created.",
            //         body: "Come meet your groupmates, " + otherUserName[0] + " and " + otherUserName[1] + ".",
            //     },
            //     apns: {
            //         payload: {
            //             aps: {
            //                 category: "chat",
            //                 badge: 1
            //             }
            //         },
            //     },
            //     data: {
            //         podID: podID
            //     },
            //     token: token,
            // }
            // const response = await admin.messaging().send(message)
            // console.log("Community Pod Created messaging response: ", response)
    // } else {
    //     console.log("USER LOGGED OUT")
    // }
            const title = "Your " + catagoryOrSubcatagory + " group has been created."
            const body = "Come meet your groupmates, " + otherUserName[0] + " and " + otherUserName[1] + "."
            const category = "chat"
            sendNotification(title, body, category, podID, tokenArray)


    });

}
function convertLocalTimeHabitToGMTTime(localTimeHHMM: number, secondsFromGMT: number) : number {

    const hoursFromGMT = secondsFromGMT / 3600

    let convertedTime = localTimeHHMM - hoursFromGMT * 100
    
    //converted time goes into next day so we have to adjust the time to make it in the morning of the next day
    if (convertedTime >= 2400) {
        convertedTime = convertedTime - 2400
    }

    //converted time goes back into previous day so we have to adjust the time to make it in the night of the last day
    if (convertedTime < 0) {
        convertedTime = convertedTime + 2400
    }
    return convertedTime
    
}

//Input: array of [alias, podID, token]
//sends primary habit reminder notification for each user coorosplonding to each thruple
//sends friend reminder notification for each group member that just recieved a primary habit reminder 
//sets somethingNew = true for both primary users and group members
//sets missingVerify to messages collection in firestore
async function getTokenArrayFromPodIDAlias(element: string[], listOfPods: FirebaseFirestore.DocumentData[]) : Promise<string[]> {

    console.log("IN addToken LOOP, element: ", element)
    const elementAlias = element[0]
    const elementPodID = element[1]

    const currentPodList = listOfPods.filter(pod => (pod.podID === elementPodID))
    const currentPod = currentPodList[0]
    console.log("IN addToken AFTER FILTER, currentPodList Length: ", currentPodList.length)
    const memberUIDDict = currentPod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
    
    const uid = memberUIDDict[elementAlias] as string
    const user = await getUser(uid) as FirebaseFirestore.DocumentData
    const tokenArray = user.token as string[]
    console.log("BOTTOM OF addToken LOOP, pushing token, [elementAliaselementPodID]: ", element, tokenArray)

    return tokenArray
}
function sendPrimaryHabitReminder(aliasPodIDTokenThruple: string[][], listOfPods: FirebaseFirestore.DocumentData[]) {



    aliasPodIDTokenThruple.forEach(async element => {
        let tokenArray = await getTokenArrayFromPodIDAlias(element, listOfPods)
        //console.log("IN SEND, current Element: ", element)
        const elementAlias = element[0]
        const elementPodId = element[1] 
        // const elementToken = element[2]

        

        const currentPodList = listOfPods.filter(pod => (pod.podID === elementPodId))
        //console.log("IN SEND, currentPodListAfterFilter LENGTH: ", currentPodList.length)
        const currentPod = currentPodList[0]


        //const currentAliasTupleList = aliasesAndPodIDs.filter(aliasPodIDTuple => (aliasPodIDTuple[1] === currentPod.podID))
        //currentAliasTupleList is the [alias, podID] that fits the current pod
        //console.log("IN SEND, currentAliasTupleList: ", currentAliasTupleList)
        //const currentAliasTuple = currentAliasTupleList[0]
        //const currentAlias = currentAliasTuple[0] 



        const memberPhraseDict = currentPod.memberAliasesAndReminderPhrase as FirebaseFirestore.DocumentData
        const reminderPhrase = memberPhraseDict[elementAlias] as string
        const memberHabitDict = currentPod.memberAliasesAndHabit as FirebaseFirestore.DocumentData
        const memberHabit = memberHabitDict[elementAlias] as string

        
    //     if (elementToken !== "Logged Out") {
    //         console.log("IN SEND, CRAFTING MESSAGE FOR POD ID, : ", elementPodId)
    //         const message = {
    //             notification: {
    //                 title: memberHabit + " reminder!",
    //                 body: reminderPhrase,
                    
    //             },
    //             apns: {
    //                 payload: {
    //                 aps: {
    //                     category: "chat",
    //                     badge: 1,
    //                     sound: "NOTIFICATIONV1.wav"
        
    //                 }
    //                 },
                    
    //             },
                
    //             data: {
    //                 podID: elementPodId
    //             },
    //             token: elementToken,
    //         }

    //         //console.log("IN SEND, SENDING MESSAGE...")
    //         admin.messaging().send(message)
    //         .then(() => {
    //             console.log("SENT PRIMARY HABIT REMINDER WITH FOR [alias, podID, token] = ", element)
    //         })
    //         .catch((error)=>{
    //             console.log(error)
    //         })
            
    // } else {
    //     console.log("USER LOGGED OUT SO NO NOTIFICATION SENT")
    // }
        let primaryHabitNotificationTitle = memberHabit + " reminder!"
        let primaryHabitNotificationBody = reminderPhrase
        let category = "chat"
        let podID = elementPodId


        sendNotification(primaryHabitNotificationTitle, primaryHabitNotificationBody, category, podID, tokenArray)
        const aliases = Object.keys(currentPod.memberAliasesAndIDs)
        for (const alias of aliases) {
            somethingNewInPodForUser(podID, alias)
        }


        sendFriendHabitReminder(currentPod, elementAlias)
        
        const memberAliasesUserID = currentPod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
        const userID = memberAliasesUserID[elementAlias] as string

        sendMissingVerify(elementPodId, userID, elementAlias)
        .then(()=>{
            console.log("Successfuly exited MISSING VERIFY for [podID, userID, elementAlias] = ", [elementPodId, userID, elementAlias])
        })
        .catch((error) =>{
            console.log(error)
        })



    })
}

function sendNotification(title: string, body: string, category: string, podID: string, tokenArray: string[]) {


    //let messageArray = []
    for (const token of tokenArray) {
        const message = {
            notification: {
                title: title,
                body: body,
                
            },
            apns: {
                payload: {
                aps: {
                    category: category,
                    badge: 1,
                    sound: "NOTIFICATIONV1.wav"
    
                }
                },
                
            },
            
            data: {
                podID: podID
            },
            token: token
        }
    //    messageArray.push(message)
    //    admin.messaging().sendAll(messageArray)
    //    .then(() => {
    //        console.log("sent notification group successfully")
    //    })
    //    .catch((error)=>{
    //        console.log(error)
    //    })
    console.log("token: ", token)
    console.log(message)
        admin.messaging().send(message)
            .then(() => {
                console.log("sent notification: " +  title)
            })
            .catch((error)=>{
                console.log(error)
            })
    }
    // if (messageArray.length != 0) {

    //     console.e
    // }

}

//Input array of [alias, podID]
//Output array of [alias, podID, token]
// async function addTokenToAliasPodIDTuple(podsToAliasWithToken: string[][], listOfPods: FirebaseFirestore.DocumentData[]): Promise<string[][]>{
//     const aliasPodIDTokenThruple: any = []

//     for (const element of podsToAliasWithToken) {

//         console.log("IN addToken LOOP, element: ", element)
//         const elementAlias = element[0]
//         const elementPodID = element[1]

//         const currentPodList = listOfPods.filter(pod => (pod.podID === elementPodID))
//         const currentPod = currentPodList[0]
//         console.log("IN addToken AFTER FILTER, currentPodList Length: ", currentPodList.length)
//         const memberUIDDict = currentPod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
        
//         const uid = memberUIDDict[elementAlias] as string
//         const user = await getUser(uid) as FirebaseFirestore.DocumentData
//         const token = user.token as string[]
//         console.log("BOTTOM OF addToken LOOP, pushing [elementAlias, token, elementPodID]: ", [elementAlias, token, elementPodID])
//         aliasPodIDTokenThruple.push([elementAlias, elementPodID, token])

//     }
//     console.log("RETURNING FROM addToken WITH aliasPodIDTokenThruple: ", aliasPodIDTokenThruple)
//     return aliasPodIDTokenThruple
// }


function dayIndexInLocalTime(timeAsHHMM: number, secondsFromGMT: number) : number {
    const todayDate = new Date()
    const dayIndex = todayDate.getDay()

    const convertedGMTTime = convertLocalTimeHabitToGMTTime(timeAsHHMM, secondsFromGMT)


    //if local time is ahead of server time, normally you would expect local time to be greater than serverTime, 
    //if local time is not greater, that means that local time is already on the next day of the week and you need to INCREMENT the day index to get the local day,
    //unless the new dayIndex === 7, then you are on the start of a new week in localTime, which is dayIndex === 0
    if (secondsFromGMT > 0 && convertedGMTTime > timeAsHHMM) {
        if (dayIndex + 1 === 7) {
            return 0 
        } else {
            return dayIndex + 1
        }
        
    } 
    
    //if local time is behind server time, normally you would expect local time to be less than ServerTime
    //if local time is greater than server time, that means local time is still on the previous day and you need to DECREMENT the day index to get the local day,
    //unless the new dayIndex === -1, then you are the end of the previous week in local time, which is dayIndex === 6
    else if (secondsFromGMT < 0 && convertedGMTTime < timeAsHHMM) {
        if (dayIndex - 1 === -1) {
            return 6 
        } else {
            return dayIndex - 1
        }
    } else {
        return dayIndex
    }
}


//takes in an array of tuples [alias, podID] that have habit times close to now and outputs 
function makeSureItsAnOnDay(podsToMakeSureItsOnDay: string[][], listOfPods: FirebaseFirestore.DocumentData[]): string[][] {
    const adjustedPodsToSendNotisTo: string[][] = []
    console.log("MAKING SURE IT IS AN ON DAY")
    console.log("ABOVE makeSure LOOP, podsToMakeSureItsOnDay: ", podsToMakeSureItsOnDay)

    podsToMakeSureItsOnDay.forEach(async element => {

        console.log("IN makeSure LOOP, current element: ", element)
        const alias = element[0] 
        const currentPodID = element[1]

        const currentPodList = listOfPods.filter(pod => (pod.podID === currentPodID))
        console.log("IN MAKE SURE AFTER FILTER, currentPodList Length: ", currentPodList.length)
        const currentPod = currentPodList[0]
        const memberDaysDict = currentPod.memberAliasesAndSchedule as FirebaseFirestore.DocumentData
        const memberTimeDict = currentPod.memberAliasesAndTime as FirebaseFirestore.DocumentData
        const memberSecondsFromGMTDict = currentPod.memberAliasesAndSecondsFromGMT as FirebaseFirestore.DocumentData
        const userTimeAsHHMM = memberTimeDict[alias] as number
        const userSecondsFromGMT = memberSecondsFromGMTDict[alias] as number


        const memberAliasesHabitDaysDict = currentPod.memberAliasesAndHabitDays as FirebaseFirestore.DocumentData


        const schedule = memberDaysDict[alias] as boolean[]

        const localDayIndex = dayIndexInLocalTime(userTimeAsHHMM, userSecondsFromGMT)

        if (schedule[localDayIndex]) {

            adjustedPodsToSendNotisTo.push(element)
            const oldDayNumber = memberAliasesHabitDaysDict[alias] as number
            const newDayNumber = oldDayNumber + 1

            memberAliasesHabitDaysDict[alias] = newDayNumber
            currentPod.memberAliasesAndHabitDays = memberAliasesHabitDaysDict

            await admin.firestore().collection("pods").doc(currentPodID).set(currentPod)
            console.log("INCREMENTED HABIT DAY FOR ELEMENT: ", element)
            
        }

    });

    return adjustedPodsToSendNotisTo
}



//takes the serverTime and uses the recorded timezone to determine whether it is
//time for a user to do his habit
//returns an array of tuples [alias, podID] for users who have their scheduled habit coming up
// function findPodsWithSameHabitTimeAsNow(nowServerNumTime: number, listOfPods: FirebaseFirestore.DocumentData[]): string[][] {
    
//     const podsAndAliasThatNeedAHabitReminder: string[][] = [] //[[a, podID], [b, podID]]

//     listOfPods.forEach(pod => {
//         const memberTimeDict = pod.memberAliasesAndTime as FirebaseFirestore.DocumentData
//         const memberSecondsFromGMTDict = pod.memberAliasesAndSecondsFromGMT as FirebaseFirestore.DocumentData
//         const podID = pod.podID as string

//         Object.keys(memberTimeDict).forEach(alias => {
//             const time = memberTimeDict[alias] as number
//             const secondsFromGMT = memberSecondsFromGMTDict[alias] as number
//             const convertedTime = convertLocalTimeHabitToGMTTime(time, secondsFromGMT)


//             if ((convertedTime - nowServerNumTime > -1  &&  convertedTime - nowServerNumTime < 5) && (pod.memberAliasesAndHasLogged[alias] === false)) {
//                 podsAndAliasThatNeedAHabitReminder.push([alias, pod.podID])
//                 console.log("Determined its time for habitReminder for [time, secondsFromGMT, convertedTime, alias, podID] ", [time, secondsFromGMT, convertedTime, alias, podID])
//             } else {
//                 console.log("Its NOT time for habitReminder for [time, secondsFromGMT, convertedTime, alias, podID] ", [time, secondsFromGMT, convertedTime, alias, podID])
//             }

//         });

//     });
//     return podsAndAliasThatNeedAHabitReminder
// }


//When a friend application is submited, 
//decide whether new application is someone creating a new group (PATH A) OR someone accepting an invitation to join a group (PATH B)
//PATH A: 
//  1)Create new group where only the group creator is a member
//          a) add podMemberInfo to messages collection in Firestore
//   2)Send group invitation notifications to invited friend users
//   3) delete application from friendPodApplications collection in Firestore
//PATH B: 
//    1) add applicants data to pod
//      2)send friendJoined notification to existing members of pod
//      3) add podMemberInfo to messages collection in Firestore
//      4)delete application from friendPodApplications collection in Firestore
export const onFriendApplicationSubmitted = functions.firestore.document("friendPodApplications/{ID}").onCreate(async change=> {

    
    const newApp = change.data() 
    const appID = newApp.appID as string


    const user = await getUser(newApp.UID) as FirebaseFirestore.DocumentData
    const userName = user.firstName as string
    //const userID = user.ID as string

    //Check if friend application is is accepting an invite which would mean joining a pod that already exists (PATH B), 
    //or an invitation to other friends which means a new pod must be created and invites must be sent (PATH A)
    if (newApp.associatedPod === null || newApp.associatedPod === undefined) {

        //THIS IS PATH A
        const inviterID = user.ID
        console.log("creating new friend pod created by "  + inviterID)
        const podID = uuidv4()
        const friends = newApp.friendIDs as string[]

        const newPod = createFriendPod(user, newApp, podID)

        friends.forEach(async ID => {
            
            await setPodInvitationForFriend(ID, user, userName, podID, newApp)
            const friendUser = await getUser(ID) as FirebaseFirestore.DocumentData
            await sendFriendPodRequestNotification(user, friendUser, newPod)
            await deleteFriendApplication(appID)

        })

    } else {

        //THIS IS PATH B
        const joinerID = user.userID
        

        const associatedPodID = newApp.associatedPod as string
        console.log(joinerID + " is joining friendPod with podID " + associatedPodID)
        const pod = await getPod(associatedPodID) as FirebaseFirestore.DocumentData

        
        await addUserToFriendPod(newApp, pod)
        friendJoinedNotification(pod, user)
        addPodMemberInfoMessage(pod, user)
        await deleteFriendApplication(appID)
        

    }

});

function friendJoinedNotification(pod: FirebaseFirestore.DocumentData, joinerUser: FirebaseFirestore.DocumentData) {
    const podMemberIDs = pod.memberAliasesAndIDs as FirebaseFirestore.DocumentData
    const podMemberAliases = ["a", "b"]
    const podID = pod.podID as string
    const joinerUserName = joinerUser.firstName as string
    podMemberAliases.forEach(async alias => {
        if (podMemberIDs[alias] !== undefined) {
            const podMemberID = podMemberIDs[alias] as string 
            const podMember = await getUser(podMemberID) as FirebaseFirestore.DocumentData
            const podMemberToken = podMember.token as string[]
            sendFriendJoinedNotification(podMemberToken, joinerUserName, podID)
            somethingNewInPodForUser(podID, alias)

        }


    });


}
function sendFriendJoinedNotification(tokenArray: string[], friendName: string, podID: string) {

    // if (token !== "Logged Out") {
    //     const message = {
    //         notification: {
    //             title: friendName + " joined your habit group.",
    //             body: "Say hi!",
    //         },
    //         apns: {
    //             payload: {
    //             aps: {
    //                 category: "chat",
    //                 badge: 1

    //             }
    //             },
                
    //         },
    //         data: {
    //             podID: podID
    //         },
            
    //         token: token,
    //     }
    //     admin.messaging().send(message)
    //     .then( async () =>
    //         console.log("FRIEND JOINED GROUP NOTIFICATION SUCCESSFULLY SENT")
            
    //     )
    //     .catch( (err) =>
    //         console.log(err)
    //     )
    let title = friendName + " joined your habit group."
    let body = "Say hi!"
    let category = "chat"
    sendNotification(title, body, category, podID, tokenArray)
    
}

async function setPodInvitationForFriend(recievedInviteUserID: string, inviterUser: FirebaseFirestore.DocumentData, userName: string, podID: string, inviterApplication: FirebaseFirestore.DocumentData) {

    const inviterFirstName = inviterUser.firstName as string
    const inviterLastName = inviterUser.lastName as string
    const inviterUserID = inviterUser.ID as string

    const pendingPodID = uuidv4()



    const recievedInviteUser = await getUser(recievedInviteUserID) as FirebaseFirestore.DocumentData
    const recievedInviteUserPendingPods = recievedInviteUser.pendingPodIDs as string[]
    recievedInviteUserPendingPods.push(pendingPodID)

    let isFriendPodLockedIn = false

    if (inviterApplication.hasOwnProperty('isFriendPodLocked')) {
        console.log("inviterApplication.hasOwnProperty(isFriendPodLocked")
        isFriendPodLockedIn  = inviterApplication.isFriendPodLocked

    } else {
        isFriendPodLockedIn = false
        console.log("no isFriendPodLocked in")

    }

    await admin.firestore().collection("users").doc(recievedInviteUserID).update( {
        pendingPodIDs : recievedInviteUserPendingPods
    })
    const commitmentLength = inviterApplication.commitmentLength as number

    const pendingPod = {

        UID: recievedInviteUserID,
        id: pendingPodID,
        communityOrFriendGroup: "Friend",
        podIDIfFriendInvite: podID,
        friendWhoSentInvite: inviterUserID,
        friendNameWhoSentInvite: inviterFirstName + " " +  inviterLastName,
        friendInviteMessage: inviterApplication.friendInviteMessage,
        communityCatagoryAppliedFor: null,
        communityPodETABottom: null,
        communityPodETATop: null,
        dateCreated: admin.firestore.Timestamp.now(),
        commitmentLength: commitmentLength, 
        isFriendPodLockedIn: isFriendPodLockedIn


    }
    await admin.firestore().collection("pendingPods").doc(pendingPodID).set(pendingPod)

}

function createFriendPod(creatorUser: FirebaseFirestore.DocumentData, creatorApp: FirebaseFirestore.DocumentData, podID: string): FirebaseFirestore.DocumentData {

    let catagoryOrSubcatagory = ""
    if (creatorApp.subCatagory !== undefined && creatorApp.subCatagory !== "N/A") {
        catagoryOrSubcatagory = creatorApp.subCatagory
    } else {
        catagoryOrSubcatagory = creatorApp.catagory
    }


    let podName = creatorUser.firstName + "'s " + "friend" + " group"
    if (creatorApp.hasOwnProperty('isFriendPodLocked')) {
        if (creatorApp.isFriendPodLocked) {
            console.log("Friend pod is locked, using custom name: ", creatorUser.firstName + "'s " + catagoryOrSubcatagory + " group")
            podName = creatorUser.firstName + "'s " + catagoryOrSubcatagory + " group"
        } else {
            console.log("Friend Pod is NOT locked in")
        }
    }





    const newPod : FirebaseFirestore.DocumentData = {

        "communityOrFriendGroup": "Friend",
        "habit" : null,
        "memberAliasesAndIDs": {a: creatorApp.UID},
        "memberAliasesAndTime": {a : creatorApp.timeOfDay},
        "memberAliasesAndReminderPhrase": {a: creatorApp.reminderPhrase},
        "memberAliasesAndLogPhrase": {a: creatorApp.logPhrase},
        "memberAliasesAndSchedule": {a: creatorApp.daysOfTheWeek},
        "memberAliasesAndScore": {a : 0},
        "memberAliasesAndColorCode": {a: 0},
        "memberAliasesAndName": {a: creatorUser.firstName},
        "podID": podID,
        "podName": podName,
        "memberAliasesAndHasLogged" : {a: false},
        "invitedFriendIDs" : creatorApp.friendIDs,
        "dayNumber" : 0,
        "dayLimit" : creatorApp.commitmentLength , 
        "memberAliasesAndSecondsFromGMT": {a: creatorApp.secondsFromGMT},
        "memberAliasesAndHabitDays" : {a : 0},
        "memberAliasesAndHabit" : {a : catagoryOrSubcatagory}, 
        "memberAliasesAndSomethingNew" : {a : true},
        "dateCreated" : creatorApp.dateCreated
    }

    admin.firestore().collection("pods").doc(podID).set(newPod)
    .then(async() => {
        console.log("new friend pod successfully create")
        let creatorUserPodsApartOf = creatorUser.podsApartOfID as string[]
        creatorUserPodsApartOf = creatorUserPodsApartOf.filter(id => id !== "Waiting for new group")
        creatorUserPodsApartOf.push(podID)
        
        admin.firestore().collection("users").doc(creatorUser.ID).update( {

            podsApartOfID : creatorUserPodsApartOf
        })
        .then(() => {
            console.log("pod Invitation sent")
            addBuddyUpBotWelcomeMessage(newPod)   
            addPodMemberInfoMessage(newPod, creatorUser) 

        })
        .catch( err => {
            console.log(err)
        })

    })
    .catch( err => {
        console.log(err)
    })
    return newPod
}

function addPodMemberInfoMessage(newPod: FirebaseFirestore.DocumentData, newUser : FirebaseFirestore.DocumentData) {
    const podID = newPod.podID as string
    const messageID = uuidv4()
    const userID = newUser.ID as string
    admin.firestore().collection("messages").doc(podID).collection(podID).doc(messageID).set({
        "id" : admin.firestore.Timestamp.now(),
        "newDay" : false,
        "senderID": userID,
        "text": "", //TODO: WRITE GOOD BUDDY UP MESSAGE
        "type": "Info",
        "messageID" : messageID
   
    })
    .then(() => {
        console.log("ADDED IN BUDDYUP BOT WELCOME MESSAGE")
    })
    .catch( err => {
        console.log(err)
    })
}

async function getUsersPendingPod(userID: string): Promise <FirebaseFirestore.DocumentData[] | void> {
    console.log("Getting pendingPods with for UID " + userID)
    
    return admin.firestore().collection("pendingPods").where("UID","==", userID).get()
    .then( querySnapshot => {
        const docs = querySnapshot.docs
        const pendingPods = docs.map(doc => doc.data())
        
        return pendingPods
        


    })
    .catch( err => {
        console.log(err)
        return 
    })
    
}

async function addUserToFriendPod(userPodApp: FirebaseFirestore.DocumentData, pod: FirebaseFirestore.DocumentData) {
    //const pod = await getPod(podID) as FirebaseFirestore.DocumentData
    const podID = pod.podID as string
    const userID = userPodApp.UID as string
    const user = await getUser(userID) as FirebaseFirestore.DocumentData
    const userPendingPods = await getUsersPendingPod(userID) as FirebaseFirestore.DocumentData[]
    const thisPendingPod = userPendingPods.filter(pendingPod => pendingPod.podIDIfFriendInvite === podID)[0]
    const thisPendingPodID = thisPendingPod.id as string

    const podMemberAliasAndIDs = pod.memberAliasesAndIDs as {string : string}

    //const userPodAppID = userPodApp.appID as string
    const numberOfMembers = Object.keys(podMemberAliasAndIDs).length
    const constters = "abcdefghijklmnopqrstuvwxyz"
    const aliasconstter = constters.charAt(numberOfMembers)

    if (userPodApp.subCatagory === "N/A") {
        pod.memberAliasesAndHabit[aliasconstter] = userPodApp.catagory

    } else {
        pod.memberAliasesAndHabit[aliasconstter] = userPodApp.subCatagory
    }

    console.log("Alias constter for new member of Friend Pod is: " + aliasconstter)
    pod.memberAliasesAndIDs[aliasconstter] = userID
    pod.memberAliasesAndTime[aliasconstter] = userPodApp.timeOfDay
    pod.memberAliasesAndReminderPhrase[aliasconstter] = userPodApp.reminderPhrase
    pod.memberAliasesAndLogPhrase[aliasconstter] = userPodApp.logPhrase
    pod.memberAliasesAndScore[aliasconstter] = 0
    pod.memberAliasesAndColorCode[aliasconstter] = numberOfMembers
    pod.memberAliasesAndName[aliasconstter] = user.firstName
    pod.memberAliasesAndSchedule[aliasconstter] = userPodApp.daysOfTheWeek
    pod.memberAliasesAndHasLogged[aliasconstter] = false
    pod.memberAliasesAndSecondsFromGMT[aliasconstter] = userPodApp.secondsFromGMT
    pod.memberAliasesAndHabitDays[aliasconstter] = 0
    pod.memberAliasesAndSomethingNew[aliasconstter] = true
    
    

    let invitedFriendIDs = pod.invitedFriendIDs as string[]
    invitedFriendIDs = invitedFriendIDs.filter(UID => UID !== userID)
    pod.invitedFriendIDs = invitedFriendIDs

    admin.firestore().collection("pods").doc(podID).set(pod)
    .then(() => {
        console.log("user successfully added to friend pod after accepting of invitation")
        console.log("moving on to delete pendingPod")
        const currentUserPods = user.podsApartOfID as string[]
        let currentUserPendingPods = user.pendingPodIDs as string[]
        currentUserPendingPods = currentUserPendingPods.filter(ID => ID !== thisPendingPodID)
        //currentUserPods = currentUserPods.filter(ID => !(ID.includes("Friend Pod Request") && ID.includes(podID)))
        currentUserPods.push(podID)

        admin.firestore().collection("users").doc(userID).update( {
            pendingPodIDs : currentUserPendingPods, 
            podsApartOfID : currentUserPods
        })
        .then(() => {
            console.log("Friend User pod list updated")
            admin.firestore().collection("pendingPods").doc(thisPendingPodID).delete()
            .then(() => {
                console.log("deleted pendingPod")
                        })
            .catch( err => {
                console.log(err)
            })


        })
        .catch( err => {
            console.log(err)
        })

    })
    .catch( err => {
        console.log(err)
    })

}


function getPod(podID: string): Promise <FirebaseFirestore.DocumentData | void> {
    
    let podData : FirebaseFirestore.DocumentData
    return admin.firestore().collection("pods").doc(podID).get() 
    .then( querySnapshot => {
        podData = querySnapshot.data() as FirebaseFirestore.DocumentData
        console.log("Retrieved Pod Data with podID " + podID)
        return podData
        


    })
    .catch( err => {
        console.log(err)
        return 
    })
    
}


async function deleteFriendApplication(appID: string) {
    await admin.firestore().collection("friendPodApplications").doc(appID).delete()
    
    .then(() => {
        console.log("friendApplication successfully deleted")


    })
    .catch( err => {
        console.log(err)
    })
}




//Every 5 minutes, check community podApplications to see if any new pods should be created
export const pendingApplicationsSchedule = functions.pubsub.schedule("*/5 * * * *").onRun(async (context) => {
    admin.firestore().collection('podApplications').orderBy("myTimestamp").get()
    .then(async querySnapshot => {
        const documents = querySnapshot.docs
        const applications = documents.map(doc => doc.data())




        let generalLeftovers : FirebaseFirestore.DocumentData[] = []

        //EXERCISE SECTION
        let leftoversExercise : FirebaseFirestore.DocumentData[] = []
        const exercise = applications.filter(application =>  application.catagory === "Exercise")
        const weightLifting = exercise.filter(exerciseApplication => exerciseApplication.subCatagory === "Weight Lifting")
        const running = exercise.filter(app => app.subCatagory === "Running")
        const yoga = exercise.filter(app => app.subCatagory === "Yoga")
        const sports = exercise.filter(app => app.subCatagory === "Sports")
        const otherExercise = exercise.filter(app => !["Weight Lifting", "Running", "Yoga", "Sports"].includes(app.subCatagory))


        const formPodExercisePromises : Promise<FirebaseFirestore.DocumentData[]>[] = []
        formPodExercisePromises.push(formPod(running, "Running"))
        formPodExercisePromises.push(formPod(yoga, "Yoga"))
        formPodExercisePromises.push(formPod(sports, "Sports"))
        formPodExercisePromises.push(formPod(otherExercise, "Exercise"))
        formPodExercisePromises.push(formPod(weightLifting, "Weight Lifting"))


        const allExerciseSubcatagories = await Promise.all(formPodExercisePromises) 
        allExerciseSubcatagories.forEach(leftoversExerciseSubcatagory => {
            let count = 0
            if (leftoversExerciseSubcatagory.length !== 0) {
                console.log((leftoversExerciseSubcatagory).map(app => "all exercise leftovers user:  " + app.UID + " " + app.subCatagory + " " + count.toString() + " of " + leftoversExerciseSubcatagory.length))
                leftoversExercise = leftoversExercise.concat(leftoversExerciseSubcatagory)
                count += 1
            }
        })




        console.log("GENERAL EXERCISE AFTER ALL CATAGORIES HAVE BEEN ADDRESSED")





        //MEDITATION SECTION
        const meditation = applications.filter(application => application.catagory === "Meditation")




        //DIETING SECTION
        const dieting = applications.filter(application => application.catagory === "Dieting")
        const keto = dieting.filter(dietingApp => dietingApp.subCatagory === "Keto Dieting")
        const vegan = dieting.filter(dietingApp => dietingApp.subCatagory === "Vegan Dieting")
        const paleo = dieting.filter(dietingApp => dietingApp.subCatagory === "Paleo Dieting")
        const water = dieting.filter(dietingApp => dietingApp.subCatagory === "Drinking Water")
        const otherDieting = dieting.filter(dietingApp => !["Keto Dieting", "Vegan Dieting", "Paleo Dieting"].includes(dietingApp.subCatagory))

        let leftoversDieting: FirebaseFirestore.DocumentData[] = []



        const formPodDietingPromises : Promise<FirebaseFirestore.DocumentData[]>[] = []
        formPodDietingPromises.push(formPod(keto, "Keto Dieting"))
        formPodDietingPromises.push(formPod(vegan, "Vegan Dieting"))
        formPodDietingPromises.push(formPod(paleo, "Paleo Dieting"))
        formPodDietingPromises.push(formPod(water, "Drinking Water"))
        formPodDietingPromises.push(formPod(otherDieting, "Dieting"))


        const allDietingSubcatagories = await Promise.all(formPodDietingPromises) 


        allDietingSubcatagories
        .forEach(leftoversDietingSubcatagory => {
            if (leftoversDietingSubcatagory.length !== 0) {
                console.log((leftoversDietingSubcatagory).map(app => "all dieting leftovers user:  " + app.UID + " " + app.subCatagory + " of " + leftoversDietingSubcatagory.length))
                leftoversDieting = leftoversDieting.concat(leftoversDietingSubcatagory)
            }
        })

        //JOURNALING SECTION
        const journaling = applications.filter(application => application.catagory === "Journaling")







        //CREATIVE WORK
        const creativeWork = applications.filter(application => application.catagory === "Creative Work")
        //["Music", "Writing", "Programming", "Drawing", "Other"]
        const music = creativeWork.filter(app => app.subCatagory === "Practicing Music")
        const writing = creativeWork.filter(app => app.subCatagory === "Writing")
        const programming = creativeWork.filter(app => app.subCatagory === "Programming")
        const drawing = creativeWork.filter(app => app.subCatagory === "Visual Art")
        const otherCreative = creativeWork.filter(app => !["Practicing Music", "Writing", "Programming", "Visual Art"].includes(app.subCatagory))
        let leftoversCreative: FirebaseFirestore.DocumentData[] = []


        const formPodCreativePromises : Promise<FirebaseFirestore.DocumentData[]>[] = []
        formPodCreativePromises.push(formPod(music, "Practicing Music"))
        formPodCreativePromises.push(formPod(writing, "Writing"))
        formPodCreativePromises.push(formPod(programming, "Programming"))
        formPodCreativePromises.push(formPod(drawing, "Drawing"))
        formPodCreativePromises.push(formPod(otherCreative, "Creative Work"))


        const allCreativeSubcatagories = await Promise.all(formPodCreativePromises) 
        allCreativeSubcatagories
        .forEach(leftoverCreativeSubcatagories => {
            if (leftoverCreativeSubcatagories.length !== 0) {
                console.log((leftoverCreativeSubcatagories).map(app => "all creative leftovers user:  " + app.UID + " " + app.subCatagory + " of " + leftoverCreativeSubcatagories.length))
                leftoversCreative = leftoversCreative.concat(leftoverCreativeSubcatagories)
            }
        })


        
        //READING
        const reading = applications.filter(application => application.catagory === "Reading")



        //study
        const study = applications.filter(application => application.catagory === "Studying")




        //Waking Up Early

        const wakeUp = applications.filter(application => application.catagory === "Waking Up Early")


        //OTHER
        const other = applications.filter(application => application.catagory === "Other")



        //OLD APPS GET PUT TOGETHER, EVERONE ELSE WAITS
        // const currentTimeStamp = admin.firestore.Timestamp.now().toDate() 
        
        const allCatagoryPromises : Promise<FirebaseFirestore.DocumentData[]>[] = []
        allCatagoryPromises.push(formPod(leftoversExercise, "Exercise"))
        allCatagoryPromises.push(formPod(leftoversDieting, "Dieting"))
        allCatagoryPromises.push(formPod(leftoversCreative, "Creative Work"))
        allCatagoryPromises.push(formPod(journaling, "Journaling"))
        allCatagoryPromises.push(formPod(meditation, "Meditation"))
        allCatagoryPromises.push(formPod(reading, "Reading"))
        allCatagoryPromises.push(formPod(study, "Studying"))
        allCatagoryPromises.push(formPod(wakeUp, "Waking Up Early"))
        allCatagoryPromises.push(formPod(other, "General"))

        const allCatagoryLeftovers = await Promise.all(allCatagoryPromises)
        allCatagoryLeftovers
        .forEach(catagoryLeftover => {
            if (catagoryLeftover.length !== 0) {
                console.log((catagoryLeftover).map(app => "all catagory leftover user:  " + app.UID + " " + app.catagory + " of " + catagoryLeftover.length))
                generalLeftovers = generalLeftovers.concat(catagoryLeftover)
            }
        })


        const oldGeneralLeftovers = getOldApps(generalLeftovers, 1)//generalLeftovers.filter(app => currentTimeStamp.valueOf() > 1 * 3600000 - app.myTimestamp.toDate().valueOf())

        const neverGotPlaced = await formPod(oldGeneralLeftovers, "Habit") 
        console.log(neverGotPlaced.length, " old apps didn't get placed in this cycle")
        console.log("DONE WITH A COMMUNITY POD CYCLE")


        
        })
    .catch( err => {
        console.log(err)
    })
});



async function formPod(catagoryArray: FirebaseFirestore.DocumentData[], habit: string): Promise<FirebaseFirestore.DocumentData[]> {
    let leftovers: FirebaseFirestore.DocumentData[] = [] 

    let catagory = catagoryArray //full list of podApplications sorted within catagory by time in application queue


    console.log("In formPod with habit, " + habit + ", the catagory.length = ", catagory.length)
    let sameApplicantOrBanList: FirebaseFirestore.DocumentData[] = []
    let podApplicationsForNewPod : FirebaseFirestore.DocumentData[] = []

    while (catagory.length > 2) {
        console.log("In while for " + habit + " loop catagory.length > 2")


        //TODO: POD SELECTION PROCESS. MAY REQUIRE a selectMembers(catagory) => [podApp1, podApp2, podApp3] 
        //then filter these pods out from remaining apps
        //currently the pod selection process only is done by time. Consider adding timeOfDay and daysOfWeek consideration.
        podApplicationsForNewPod = catagory.slice(0,3)
        catagory = catagory.slice(3)

        let viableCheck = checkIfUnique(podApplicationsForNewPod)
        while (viableCheck !== 0) {
            //console.log("users not unique")
            //takes the second application thats from the same user out from the pod and puts in leftovers to be evaluated 
            //time at the end
            sameApplicantOrBanList = sameApplicantOrBanList.concat(podApplicationsForNewPod.splice(viableCheck, 1)) 
            
            //if we still have enough applications for a pod, add a new application and test uniqueness again
            if (catagory.length > 0) {

                podApplicationsForNewPod = podApplicationsForNewPod.concat(catagory.splice(0, 1))
                //TODO: again here, all we do is find one more based on time in application queue. May require an addAdditional([podApp1, podApp2], catagoryArray)
                //console.log("checking new pod in " + habit)
                viableCheck = checkIfUnique(podApplicationsForNewPod)
            } else {
                //if we don't have enough applications left in this catagory break the viable check loop 
                break
            }

        } 
        //if we had to break the viable check loop without coming up with a viable pod, break the whole podFormation loop
        if (viableCheck !== 0) {
            console.log("couldn't find a pod that passes the SAME USER test within " + habit + ". Likely low application numbers and multiple applications from same user.")
            break
        }
        //ONCE WE'VE GOTTEN OUT OF THE WHILE LOOP WE'VE SUCESSFULLY GOTTEN THREE MEMBERS FOR A POD


        //get the coorosponding users from each app
        const user1UID = podApplicationsForNewPod[0].UID
        const user2UID = podApplicationsForNewPod[1].UID
        const user3UID = podApplicationsForNewPod[2].UID


        const usersInPod : FirebaseFirestore.DocumentData[] = await Promise.all([getUser(user1UID) as FirebaseFirestore.DocumentData, 
            getUser(user2UID) as FirebaseFirestore.DocumentData, getUser(user3UID) as FirebaseFirestore.DocumentData])


        //check if we have any users on other users banned lists
        let bannedListCheck = checkIfOnBanList(usersInPod)
        while (bannedListCheck !== -1) {
            console.log("In " + habit + " one user is on another's banned list")
            sameApplicantOrBanList.concat(podApplicationsForNewPod.splice(bannedListCheck, 1))
            usersInPod.splice(bannedListCheck, 1)

            //if we still have enough applications for a pod, add a new application and test bans again
            if (catagory.length > 0 && checkIfUnique(podApplicationsForNewPod) === 0)  {
                const newPodAppSplice = catagory.splice(0, 1)[0]
                podApplicationsForNewPod.concat(newPodAppSplice)
                bannedListCheck = checkIfUnique(podApplicationsForNewPod)

                const newUser = await getUser(newPodAppSplice[0].UID) as FirebaseFirestore.DocumentData
                if (newUser === undefined || newUser === null) {
                    console.log("could now load user data. breaking loop")
                    break
                }
                usersInPod.push(newUser)


            } else { 
                

                break
            }


        }

        //if we couldn't form a pod that doesn't include banned users, then break while loop
        if (bannedListCheck !== -1 || checkIfUnique(podApplicationsForNewPod) !== 0) {
            console.log("couldn't find a pod that passes BANNED USERS within " + habit + ". Likely low application numbers and users on banned list.")
            break
        }

        
        console.log("PASSED VIABLE CHECK WITH: ")
        console.log(podApplicationsForNewPod.map(app => app.appID))
        console.log("THESE FAILED VIABLE CHECK: ")
        console.log(sameApplicantOrBanList.map(app => app.appID))

        //write the pod to firestore
        console.log("ABOUT TO WRITE NEW " + habit + " POD")
        //console.log("podApplicationsForNewPod: ", podApplicationsForNewPod)
        writePod(usersInPod[0], usersInPod[1], usersInPod[2], podApplicationsForNewPod, habit)
 

    }
    catagory = catagory.concat(podApplicationsForNewPod) 
    leftovers = getOldApps(catagory.concat(sameApplicantOrBanList), 0.5)
    console.log("returning from formPod " + habit + " with leftovers.length: ", leftovers.length)
    return leftovers
}

function getOldApps(appList: FirebaseFirestore.DocumentData[], hours: number):  FirebaseFirestore.DocumentData[] {
    const leftovers: FirebaseFirestore.DocumentData[] = []
    const currentTimeStamp = admin.firestore.Timestamp.now().toDate() 
    appList.forEach(remainingApp => {
        //console.log("ITERATING THROUGH ALL APPS THAT DIDNT MAKE IT INTO A POD AND DECIDING IF THEY ARE OLD")
        if (currentTimeStamp.valueOf() - remainingApp.myTimestamp.toDate().valueOf() > 3600000 * hours){
            //console.log("app " + remainingApp.appID + " is old. Adding to leftovers")
            leftovers.push(remainingApp)
        }
        // } else {
        //     //console.log(remainingApp.myTimestamp.toDate().valueOf())
        //     //console.log(currentTimeStamp)
        //     console.log("timeCalculus : " + String(currentTimeStamp.valueOf() - remainingApp.myTimestamp.toDate().valueOf()))
        // }
    })
    return leftovers
}




function checkIfUnique(newPod: FirebaseFirestore.DocumentData[]): number {
    //console.log("CHECKING UNIQUENESS")
    if (newPod[0].UID === newPod[1].UID) {
        return 1
    } else if (newPod[1].UID === newPod[2].UID) {
        return 2
    } else if (newPod[0].UID === newPod[2].UID)  {
        return 2
    }
    else {
        return 0
    }
}

function checkIfOnBanList(users: FirebaseFirestore.DocumentData[]): number {
    console.log("CHECKING BANS")

    
    const userBannedList1 = users[0].userBannedList as string[]
    const userBannedList2 = users[1].userBannedList as string[]
    const userBannedList3 = users[2].userBannedList as string[]


    if (userBannedList1.some(UID => (UID === users[1].UID) || (UID === users[2].UID))) {
        return 0 
    } if (userBannedList2.some(UID => (UID === users[0].UID) || (UID === users[2].UID))) {
        return 1
    } if (userBannedList3.some(UID => (UID === users[0].UID) || (UID === users[1].UID))) {
        return 2
    } else return -1
    

}


function  writePod(user1: FirebaseFirestore.DocumentData, user2: FirebaseFirestore.DocumentData, user3: FirebaseFirestore.DocumentData, podApplicationsForNewPod : FirebaseFirestore.DocumentData[], habit: string)  { 
    console.log("START WRITING POD FUNCTION")
    const podID = uuidv4()
    const app1 = podApplicationsForNewPod[0]
    const app1ID = app1.appID as string
    const user1Name = user1.firstName as string
    const user1UID = user1.ID as string
    const user1Time = app1.timeOfDay as number
    const user1ReminderPhrase = app1.reminderPhrase as string
    const user1LogPhrase = app1.logPhrase as string

    let user1Habit = ""
    if (app1.subCatagory === "N/A") {
        user1Habit = app1.catagory
    } else {
        user1Habit = app1.subCatagory
    }
    //const user1AppID = user1.appID as string

    const app2 = podApplicationsForNewPod[1]
    const app2ID = app2.appID as string
    const user2Name = user2.firstName as string
    const user2UID = user2.ID as string
    const user2Time = app2.timeOfDay as number
    const user2ReminderPhrase = app2.reminderPhrase as string
    const user2LogPhrase = app2.logPhrase as string
    let user2Habit = ""

    //const user2AppID = user1.appID as string
    if (app2.subCatagory === "N/A") {
        user2Habit = app2.catagory
    } else {
        user2Habit = app2.subCatagory
    }

    const app3 = podApplicationsForNewPod[2]
    const app3ID = app3.appID as string
    const user3Name = user3.firstName as string
    const user3UID = user3.ID as string
    const user3Time = app3.timeOfDay as number
    const user3ReminderPhrase = app3.reminderPhrase as string
    const user3LogPhrase = app3.logPhrase as string
    let user3Habit = ""

    //const user3AppID = user1.appID as string
    if (app3.subCatagory === "N/A") {
        user3Habit = app3.catagory
    } else {
        user3Habit = app3.subCatagory
    }


    //const memberIDsAndTime = { app1UID : app1Time , app2UID: app2Time, app3UID: app3Time}

    let habitMutable = habit
    if (habit === "Other"  || habit === null || habit === "General") {
        habitMutable = "General"
    }

    console.log("START BUILDING POD")
    const newPod : FirebaseFirestore.DocumentData = {

        "communityOrFriendGroup": "Community",
        "habit" : habitMutable,
        "memberAliasesAndIDs": {a: user1UID, b: user2UID, c: user3UID},
        "memberAliasesAndTime": { a : user1Time , b : user2Time, c : user3Time},
        "memberAliasesAndReminderPhrase": {a: user1ReminderPhrase, b : user2ReminderPhrase, c : user3ReminderPhrase},
        "memberAliasesAndLogPhrase" : {a: user1LogPhrase, b : user2LogPhrase, c : user3LogPhrase},
        "memberAliasesAndSchedule": {a: app1.daysOfTheWeek, b: app2.daysOfTheWeek, c: app3.daysOfTheWeek},
        "memberAliasesAndScore": {a : 0, b : 0, c : 0},
        "memberAliasesAndColorCode": {a: 0, b: 1, c : 2},
        "memberAliasesAndName": {a: user1Name, b: user2Name, c: user3Name},
        "podID": podID,
        "podName": habitMutable + " group",
        "memberAliasesAndHasLogged": {a : false, b : false, c : false},
        "dayNumber" : 0,
        "dayLimit": app1.commitmentLength,
        "memberAliasesAndSecondsFromGMT": {a: app1.secondsFromGMT, b:  app2.secondsFromGMT, c: app3.secondsFromGMT},
        "memberAliasesAndHabitDays" : {a : 0, b : 0, c : 0}, 
        "memberAliasesAndHabit" : {a : user1Habit, b: user2Habit, c : user3Habit},
        "memberAliasesAndSomethingNew" : {a : true, b : true, c : true},
        "dateCreated" : FirebaseFirestore.Timestamp.now()
        
    }

    console.log("WRITING POD TO FIREBASE")
    admin.firestore().collection("pods").doc(podID).set(newPod)
    .then(async ()=>{
        console.log("FINISHED WRITING POD, entering .then ")
        //delete podApplications
        const user1PodsApartOfID = user1.podsApartOfID as string[]
        const user2PodsApartOfID = user2.podsApartOfID as string[]
        const user3PodsApartOfID = user3.podsApartOfID as string[]



        let user1PendingPodIDs = user1.pendingPodIDs as string[]
        let user2PendingPodIDs = user2.pendingPodIDs as string[]
        let user3PendingPodIDs = user3.pendingPodIDs as string[]


        console.log("FILTERING OUT PENDING POD IDs")
        user1PendingPodIDs = user1PendingPodIDs.filter(ID => ID !== app1ID)
        user2PendingPodIDs = user2PendingPodIDs.filter(ID => ID !== app2ID)
        user3PendingPodIDs = user3PendingPodIDs.filter(ID => ID !== app3ID)


        console.log("ADDING NEW podID to users")
        user1PodsApartOfID.push(podID)
        user2PodsApartOfID.push(podID)
        user3PodsApartOfID.push(podID)



        const userUpdatePromises : Promise<FirebaseFirestore.WriteResult>[] = [] 
        console.log("UPDATING USERS DATA")
        
        userUpdatePromises.push(admin.firestore().collection("users").doc(user1UID).update(
            {   
                pendingPodIDs : user1PendingPodIDs, 
                podsApartOfID: user1PodsApartOfID}
        ))
        userUpdatePromises.push(admin.firestore().collection("users").doc(user2UID).update(
            {   
                pendingPodIDs : user2PendingPodIDs, 
                podsApartOfID: user2PodsApartOfID}
        ))
        userUpdatePromises.push(admin.firestore().collection("users").doc(user3UID).update(
            {   
                pendingPodIDs : user3PendingPodIDs, 
                podsApartOfID: user3PodsApartOfID
            }
            ))

        Promise.all(userUpdatePromises)
        .then(result => console.log("SUCCESSFULLY UPDATED USER DATA", result))
        .catch(err => console.log("ERRORED IN UPDATING USER DATA", err))

        
        const applicationsAndPendingPoddelete  : Promise<FirebaseFirestore.WriteResult>[] = [] 
        console.log("deleting podApplications and pending pods")
        applicationsAndPendingPoddelete.push(admin.firestore().collection("podApplications").doc(app1ID).delete())
        applicationsAndPendingPoddelete.push(admin.firestore().collection("podApplications").doc(app2ID).delete())
        applicationsAndPendingPoddelete.push(admin.firestore().collection("podApplications").doc(app3ID).delete())
        applicationsAndPendingPoddelete.push(admin.firestore().collection("pendingPods").doc(app1ID).delete())
        applicationsAndPendingPoddelete.push(admin.firestore().collection("pendingPods").doc(app2ID).delete())
        applicationsAndPendingPoddelete.push(admin.firestore().collection("pendingPods").doc(app3ID).delete())

        Promise.all(userUpdatePromises)
        .then(result => console.log("SUCCESSFULLY deleteD podApplications and PENDING PODS", result))
        .catch(err => console.log("ERRORED IN deleting podApplications and PENDING PODS", err))



        console.log("SENDING POD CREATED NOTIFICATION")
        const userArray = [user1, user2, user3] as FirebaseFirestore.DocumentData[]
       
        addBuddyUpBotWelcomeMessage(newPod)

        userArray.forEach(user => {
            addPodMemberInfoMessage(newPod, user)
        });
        await sendCommunityPodCreatedNotification(userArray, newPod)
        return
    })
    .catch( err => {
        console.log(err)
        return

    })
};


async function getUser(UID: string): Promise<void | FirebaseFirestore.DocumentData> {
    //const retrievedUser: FirebaseFirestore.DocumentData
    console.log("GETTING USER: " + UID)
    return admin.firestore().collection("users").doc(UID).get()
        .then(user => {

            return user.data()
            

        })
        .catch((error) => {
            console.log(error)
            
            

        });
}

async function getAllPods(): Promise<void | FirebaseFirestore.DocumentData> {
    console.log("GETTING ALL PODS")
    return admin.firestore().collection("pods").get()
    .then(snapshot => {
        const documents = snapshot.docs
        const pods = documents.map(doc => doc.data())
        return pods

    })
    .catch((error) => {
        console.log(error)
        return
    })
}

function deleteDataFromAlias(mapField: FirebaseFirestore.DocumentData, alias: string): FirebaseFirestore.DocumentData {
    const copyField = mapField
    delete copyField[alias]
    return copyField
}


//When a person decided they want to leave the group
//Remove their data from podType
//If their complaint is against a person, add that person's ID to their banned list
//Remove podID from user.podsApartOfID 
export const leavePod = functions.https.onCall(async (data, context) => {
    const complaintID = data.complaintID as string
    const complaint = await getComplaint(complaintID) as FirebaseFirestore.DocumentData
    const leaverID = complaint.complainerID as string 
    const leaverAlias = complaint.complainerAlias as string
    
    const podID = complaint.associatedPodID as string
    const pod = await getPod(podID) as FirebaseFirestore.DocumentData


    removePersonFromPod(pod, leaverAlias, leaverID)
    .then(() => {
        console.log("PERSON REMOVED FROM POD")

    })
    .catch((error) => {
        console.log(error)
        
    })  


    const user = await getUser(leaverID) as FirebaseFirestore.DocumentData
    let podsApartOfID = user.podsApartOfID as string[]
    let userBannedList = user.userBannedList as string[]
    podsApartOfID = podsApartOfID.filter(ID => ID !== podID)
    user.podsApartOfID = podsApartOfID
    if (complaint.type === "person") {
        const complainedAgainstIDs = complaint.complainedAgainstIDs as string[]
        userBannedList = userBannedList.concat(complainedAgainstIDs)
        user.userBannedList = userBannedList
    }

    const deletePodIDFromUserResponse = await admin.firestore().collection("users").doc(leaverID).set(user)
    console.log("delete PODID FROM USER RESPONSE: ", deletePodIDFromUserResponse)
    


})

//removes user data from pod
//If pod no longer has any members, delete pod from pods collection in Firestore
async function removePersonFromPod(pod: FirebaseFirestore.DocumentData, leaverAlias: string, leaverID: string) {

    const podID = pod.podID as string

    pod.memberAliasesAndIDs = deleteDataFromAlias(pod.memberAliasesAndIDs, leaverAlias)
    pod.memberAliasesAndTime = deleteDataFromAlias(pod.memberAliasesAndTime, leaverAlias)
    pod.memberAliasesAndReminderPhrase = deleteDataFromAlias(pod.memberAliasesAndReminderPhrase, leaverAlias)
    pod.memberAliasesAndLogPhrase = deleteDataFromAlias(pod.memberAliasesAndLogPhrase, leaverAlias)
    pod.memberAliasesAndColorCode = deleteDataFromAlias(pod.memberAliasesAndColorCode, leaverAlias)
    pod.memberAliasesAndName = deleteDataFromAlias(pod.memberAliasesAndName, leaverAlias)
    pod.memberAliasesAndSchedule = deleteDataFromAlias(pod.memberAliasesAndSchedule, leaverAlias)
    pod.memberAliasesAndHasLogged = deleteDataFromAlias(pod.memberAliasesAndHasLogged, leaverAlias)
    pod.memberAliasesAndScore = deleteDataFromAlias(pod.memberAliasesAndScore, leaverAlias)
    pod.memberAliasesAndHabitDays = deleteDataFromAlias(pod.memberAliasesAndHabitDays, leaverAlias)
    pod.memberAliasesAndHabit = deleteDataFromAlias(pod.memberAliasesAndHabit, leaverAlias)
    pod.memberAliasesAndSomethingNew = deleteDataFromAlias(pod.memberAliasesAndSomethingNew, leaverAlias)

    
    
    let invitedFriendIDs = pod.invitedFriendIDs as string[] | null

    if (invitedFriendIDs !== null  && invitedFriendIDs != undefined) {
        invitedFriendIDs = invitedFriendIDs.filter(ID => ID !== leaverID)
    }

    const deleteUserFromPodResponse = await admin.firestore().collection("pods").doc(podID).set(pod)
    console.log("delete USER FROM POD RESPONSE: ", deleteUserFromPodResponse)


    if (Object.keys(pod.memberAliasesAndIDs).length === 0) {
        console.log("LAST PERSON TO LEAVE POD, POD IS NOW EMPTY")
        const deletePodBecauseEmpty = await admin.firestore().collection("pods").doc(podID).delete()
        console.log("delete POD BECAUSE EMTY RESPONSE: ", deletePodBecauseEmpty)
        const deleteAssociatedMessages = await admin.firestore().collection("messages").doc(podID).delete()
        console.log("delete ASSOCIATED MESSAGES: ", deleteAssociatedMessages)

    } else  {
        console.log("pod.memberAliasesAndIDs is not empty: ", pod.memberAliasesAndIDs)
    }
}

async function getComplaint(complaintID: string): Promise<void | FirebaseFirestore.DocumentData> {
    //const retrievedUser: FirebaseFirestore.DocumentData
    console.log("GETTING Complaint: " + complaintID)
    return admin.firestore().collection("complaints").doc(complaintID).get()
        .then(complaint => {

            return complaint.data()
            

        })
        .catch((error) => {
            console.log(error)

        });
}