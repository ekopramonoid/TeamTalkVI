<?php

/*
 * TeamTalk 4 PHP Admin
 *
 * Copyright (c) 2005-2010, BearWare.dk
 * 
 * Contact Information:
 *
 * Bjoern D. Rasmussen
 * Bedelundvej 79
 * DK-9830 Taars
 * Denmark
 * Email: contact@bearware.dk
 * Web: http://www.bearware.dk
 * 
 * 
 * Interacting with a TeamTalk server is similar to a command line
 * interface. Basically issue a command by typing its name and press
 * Enter. The server will then process the command and issue a
 * reply. The TeamTalk protocol is, however, not a request/reply
 * protocol, i.e. the server can send commands which are not replies
 * issued by the client (you). E.g. once you have logged in you can
 * get a command from the server saying that a user has joined a
 * channel which is not related to any command you have issued. To
 * know if a command is a reply to a command you have issued you need
 * to put in the parameter "id=123" where 123 is the command ID of the
 * command you want to trace. The server will then encapsulate its
 * reply to your command in 'begin' - 'end' replies.
 *
 * Although it may sound complicated it's very simple. Say you have
 * logged on to a server and want to list all user accounts. You do
 * this by issuing the command "listaccounts id=123". The server will
 * send repond like this:
 *
 * begin id=123
 * useraccount username="ben" password="pass123" usertype=1
 * useraccount username="jill" password="pppjjj" usertype=2
 * ok
 * end id=123
 *
 * When you get the 'end' command it means there will be no more
 * commands issued by the server related to the command with the
 * specified 'id'. The 'ok' command reply means that the command
 * executed successfully. Had it not the command 'error' would have
 * been returned like in the following example:
 *
 * begin id=123
 * error number=2006 message="Command not authorized"
 * end id=123
 *
 * The 'id' parameter can be omitted which is sometimes convenient but
 * if you want to know which commands issued by the server are related
 * to a command issued by you you need to include the 'id' parameter.
 *
 *
 * Note this is not a webserver script. This script requires user
 * input from STDIN. Currently this script only allows to list, create
 * and delete user account. More will be added later...
 *
 */

echo "TeamTalk 4 PHP Admin!\r\n";
echo "Supports TeamTalk 4 protocol 4.5\r\n\r\n";
echo "Copyright (c) 2005-2013, BearWare.dk\r\n\r\n";
echo "This is a console application so don't put it on a webserver.\r\n";

/* TeamTalk 4 server's IP-address and port number */
$host = "";
$port = 0;

if(isset($argv[1]))
{
    $host = $argv[1];
    if(!isset($argv[2]))
        $port = 10333;
    else
        $port = $argv[2];
}

/* Login information */
$username = "";
$password = "";
$srvpasswd = "";
$nickname = "tt4phpadmin"; /* optional */

if(strlen($host) == 0)
{
    $host = get_userinput("Type IP-address of TeamTalk server (prefix 'tls://' in TT4Pro): ");
}

if(strlen($port) == 0)
{
    $port = get_userinput("Type TCP port number of TeamTalk server: ");
}

//TeamTalk 4 SDK Standard Edition uses raw sockets whereas TeamTalk 4
//SDK Professional Edition should prepend tls:// to the host-address,
//since the Professional Edition uses TLS-encryption
//(e.g. "tls://teamtalk.dyndns.dk").
echo "Connecting...\r\n";
$socket = fsockopen($host, $port, $errno, $errstr, 5.0);

if(!$socket)
{
    echo "Failed to connect to server";
    exit(1);
}

echo "Connected!\r\n";

//set 5 seconds as maximum to get a response from the TT server.
stream_set_timeout($socket, 5);

/* Containers for channels and users */
$channels = array();
$users = array();

/* Show quota options (only related to TT4 hosting server) */
$quota_options = FALSE;

//process 'welcome' command
if(!process_reply_cmd(0))
{
    echo "Failed to process command\r\n";
    exit(1);
}

//get authentication from console
if(strlen($username) == 0)
{
    $username = get_userparam("Type account username: ");
    $password = get_userparam("Type account password: ");
    $srvpasswd = get_userparam("Type server password: ");
    echo "\r\n";
}

//issue 'login' command with command ID #1
$cmdid = 1;
echo "Logging in...\r\n";
$cmd = "login username=\"$username\" password=\"$password\" serverpassword=\"$srvpasswd\" protocol=\"4.5\" nickname=\"$nickname\" id=$cmdid\r\n";
fwrite($socket, $cmd);

if(!process_reply_cmd($cmdid))
{
    echo "Login failed\r\n";
    exit(1);
}

while(TRUE)
{
    echo "\r\n";
    echo "What do you want to do now?\r\n";
    echo "---------------------------- USERS -----------------------------\r\n";
    echo " 1. List online users\r\n";
    echo " 2. Kick user\r\n";
    echo " 3. Move user\r\n";
    echo " 4. Op/deop user\r\n";
    echo " 5. List banned users\r\n";
    echo " 6. Ban user\r\n";
    echo " 7. Unban user\r\n";
    echo " 8. Send text message to user\r\n";
    echo "--------------------------- CHANNELS ---------------------------\r\n";
    echo "10. List active channels\r\n";
    echo "11. Create channel\r\n";
    echo "12. Update channel\r\n";
    echo "13. Delete channel\r\n";
    echo "14. Join channel\r\n";
    echo "15. Join new channel\r\n";
    echo "16. Leave channel\r\n";
    echo "17. Send text message to channel\r\n";
    echo "------------------------ USER ACCOUNTS -------------------------\r\n";
    echo "20. List user accounts\r\n";
    echo "21. Create user account\r\n";
    echo "22. Delete user account\r\n";
    echo "--------------------------- SERVER -----------------------------\r\n";
    echo "30. Change server name\r\n";
    echo "31. Change server password\r\n";
    echo "32. Change maximum number of users\r\n";
    echo "33. Change message of the day\r\n";
    echo "34. Send text message to all users on server\r\n";
    echo "35. Save server changes\r\n";
    echo "36. Query server statistics\r\n";
    if($quota_options)
    {
    echo "-------------------- QUOTA ADMINISTRATION ----------------------\r\n";
    echo "40. Set quota for bandwidth usage\r\n";
    }
    echo "--------------------------- SESSION ----------------------------\r\n";
    echo "50. Issue ping (extend session time)\r\n";
    echo "51. Exit\r\n\r\n";
    echo "Type option ID: ";

    switch(get_userinput(""))
    {
    case 1 : //List online users
        echo "Online users:\r\n";
        foreach($users as $user)
            print_r($user);
        break;
    case 2 : //Kick online user
        $cmdid++;
        $id = get_userinput("Type user ID of user to kick: ");
        $cmd = "kick userid=".$id." id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to kick user\r\n";
            exit(1);
        }
        break;
    case 3 : //Move user
        $cmdid++;
        $id = get_userinput("Type user ID of user to move: ");
        $channel = get_userparam("Type path of channel to move user to: ");
        $cmd = "moveuser userid=".$id." destchannel=\"$channel\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to move user\r\n";
            exit(1);
        }
        break;
    case 4 : //Op/deop user
        $cmdid++;
        $id = get_userinput("Type user ID of user to op: ");
        $channel = $users[$id]['channel'];
        $opstatus = get_userinput("Operator status (0/1)? ");
        $cmd = "op userid=".$id." channel=\"$channel\" opstatus=$opstatus id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to op user\r\n";
            exit(1);
        }
        break;
    case 5 : //List bans
        $cmdid++;
        $cmd = "listbans id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to list banned users\r\n";
            exit(1);
        }
        break;
    case 6 : //Ban user
        $cmdid++;
        $id = get_userinput("Type user ID of user to ban: ");
        $channel = $users[$id]['channel']; //channel=\"$channel\" 
        $cmd = "ban userid=".$id." id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to ban user\r\n";
            exit(1);
        }
        break;
    case 7 : //Unban user
        $cmdid++;
        $ipaddr = get_userparam("Type IP-address to remove from bans: ");
        $channel = $users[$id]['channel']; //channel=\"$channel\" 
        $cmd = "unban ipaddr=\"$ipaddr\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to unban IP-address\r\n";
            exit(1);
        }
        break;
    case 8 : //User text message
        $cmdid++;
        $userid = get_userinput("Type user ID of user who should receive the message: ");
        $msg = get_userparam("Type message to send to user: ");
        $cmd = "message type=1 content=\"$msg\" destuserid=$userid id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to send text message\r\n";
            exit(1);
        }
        break;
    case 10 : //List active channels
        echo "Active channels:\r\n";
        foreach($channels as $channel)
            print_r($channel);
        break;
    case 11 : //Create channel
        $cmdid++;
        $channel = get_userparam("Type path of channel to create: ");
        $password = get_userparam("Type password of new channel: ");
        $type = get_userinput("Type of channel (static=1, temporary=0): ");
        $topic = get_userparam("Type topic of new channel: ");
        $audiocodec = get_audiocodec();
        $cmd = "makechannel channel=\"$channel\" password=\"$password\" type=$type topic=\"$topic\" audiocodec=$audiocodec id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to create channel\r\n";
            exit(1);
        }
        break;
    case 12 : //Update channel
        $cmdid++;
        $channel = get_userparam("Type path of channel to update: ");
        $password = get_userparam("Type password of channel: ");
        $type = 1;
        $topic = get_userparam("Type topic of channel: ");
        $audiocodec = get_audiocodec();
        $cmd = "updatechannel channel=\"$channel\" password=\"$password\" type=$type topic=\"$topic\" audiocodec=$audiocodec id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to create channel\r\n";
            exit(1);
        }
        break;
    case 13 : //Delete channel
        $cmdid++;
        $channel = get_userparam("Type path of channel to delete: ");
        if(strlen($channel) == 0 || $channel == "/")
        {
            $res = get_userinput("Are you sure you want to delete all channels? (y/n)");
            if($res != "y" && $res != "yes")
                break;
        }
        $cmd = "removechannel channel=\"$channel\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to delete channel\r\n";
            exit(1);
        }
        break;
    case 14 : //Join channel
        $cmdid++;
        $channel = get_userparam("Type path of channel to join: ");
        $passwd = get_userparam("Type password of channel: ");
        $cmd = "join channel=\"$channel\" password=\"$passwd\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to join channel\r\n";
            exit(1);
        }
        break;
    case 15 : //Join channel new channel
        $cmdid++;
        $channel = get_userparam("Type path of channel to create and join: ");
        $password = get_userparam("Type password of new channel: ");
        $type = get_userinput("Type of channel (static=1, temporary=0): ");
        $topic = get_userparam("Type topic of new channel: ");
        $audiocodec = get_audiocodec();
        $cmd = "join channel=\"$channel\" password=\"$password\" type=$type topic=\"$topic\" audiocodec=$audiocodec id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to create channel\r\n";
            exit(1);
        }
        break;
    case 16 : //leave channel
        $cmdid++;
        $cmd = "leave id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to leave channel\r\n";
            exit(1);
        }
        break;    
    case 17 : //Send channel message
        $cmdid++;
        $channel = get_userparam("Type path of channel which should receive the message: ");
        $msg = get_userparam("Type message to send to channel: ");
        $cmd = "message type=2 content=\"$msg\" channel=\"$channel\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to send text message\r\n";
            exit(1);
        }
        break;
    case 20 : //List user accounts
        $cmdid++;
        $cmd = "listaccounts id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to list user accounts\r\n";
            exit(1);
        }
        break;
    case 21 : //Create user account
        $cmdid++;
        $username = get_userparam("Type username for account: ");
        $password = get_userparam("Type password for account: ");
        $usertype = get_userinput("User type (1=default, 2=admin): ");
        $note = get_userinput("Note: ");
        $initchan = get_userinput("Initial channel: ");
        $cmd = "newaccount username=\"$username\" password=\"$password\" usertype=$usertype note=\"$note\" channel=\"$initchan\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to create account\r\n";
            exit(1);
        }
        echo "Created user account successfully\r\n";
        break;
    case 22 : //Delete user account
        $cmdid++;
        $username = get_userparam("Type username of account to delete: ");
        $cmd = "delaccount username=\"$username\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to delete account\r\n";
            exit(1);
        }
        echo "Deleted user account successfully\r\n";
        break;
    case 30 : //Update server name
        $cmdid++;
        $srvname = get_userparam("Type new server name: ");
        $cmd = "updateserver servername=\"$srvname\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to update server\r\n";
            exit(1);
        }
        break;
    case 31 : //Update server password
        $cmdid++;
        $srvpasswd = get_userparam("Type new server password: ");
        $cmd = "updateserver serverpassword=\"$srvpasswd\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to update server\r\n";
            exit(1);
        }
        break;
    case 32 : //Update server max users
        $cmdid++;
        $maxusers = get_userinput("Type new maximum number of users on server: ");
        $cmd = "updateserver maxusers=\"$maxusers\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to update server\r\n";
            exit(1);
        }
        break;
    case 33 : //Update MOTD
        $cmdid++;
        $motd = get_userparam("Type new message of the day: ");
        $cmd = "updateserver motd=\"$motd\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to update server\r\n";
            exit(1);
        }
        break;
    case 34 : //Broadcast message
        $cmdid++;
        $msg = get_userparam("Type message to broadcast to all users: ");
        $cmd = "message type=3 content=\"$msg\" id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to send text message\r\n";
            exit(1);
        }
        break;        
    case 35 : //Save changes
        $cmdid++;
        $cmd = "saveconfig id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to save changes\r\n";
            exit(1);
        }
        break;
    case 36 :
        $cmdid++;
        $cmd = "querystats id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to query statistics\r\n";
            exit(1);
        }
        break;
    case 40 : //Set quota for bandwidth usage
        $cmdid++;
        $quota_max = get_userinput("Specify bandwidth quota before logging off users (in MB): ");
        $quota_max *= 1024*1024;
        $quota_used = get_userinput("Specify currently used quota (in MB): ");
        $quota_used *= 1024*1024;
        $cmd = "updateserver quotamax=$quota_max quotaused=$quota_used id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to update server\r\n";
            exit(1);
        }
        break;
    case 50 : //Issue ping
        $cmdid++;
        $cmd = "ping id=$cmdid\r\n";
        fwrite($socket, $cmd);
        if(!process_reply_cmd($cmdid))
        {
            echo "Failed to issue ping\r\n";
            exit(1);
        }
        echo "Session extended\r\n";
        break;
    case 51 :
        fclose($socket);
        exit(0);
    default :
        break;
    }
}

function process_reply_cmd($cmdid)
{
    global $socket, $users, $channels, $quota_options;

    //variable to keep track of the command ID which is currently
    //being processed.
    $curcmdid = 0;
    //variable to keep track of whether the $cmdid parameter
    //succeeded.
    $success = FALSE;
    while(TRUE)
    {
        //BUG: Typically the TCP recv buffer is 8192 bytes so this
        //call will fail if the command is longer.
        $line = fgets($socket);

        //do a syntax check to ensure the reply is valid.
        $cmdline = get_cmdline($line);
        if(!$cmdline)
            return FALSE;

        //extract the command name
        $cmd = get_cmd($cmdline);
        if(!$cmd)
            return FALSE;

        //process the command
        switch($cmd)
        {
        case 'welcome' :
            //welcome command (the first message when we connect
            $userid = get_int($cmdline, 'userid');
            if($userid)
                echo "Got user ID# $userid\r\n";
            $servername = get_str($cmdline, 'servername');
            echo "Server name is: " . $servername . "\r\n";
            $usertimeout = get_int($cmdline, 'usertimeout');
            if($usertimeout)
                echo "Your session will time out in $usertimeout seconds\r\n";
            break;
        case 'begin' :
            //A reply to a command ID is starting.
            $curcmdid = get_int($cmdline, 'id');
            break;
        case 'end' :
            //A reply to a command ID ended.
            if(get_int($cmdline, 'id') == $cmdid)
                return $success;
            else
                $curcmdid = 0;
            break;
        case 'error' :
            //a command failed. We check if it's the one we're waiting
            //for.
            echo $cmdline;
            if($curcmdid == $cmdid)
                $success = FALSE;
            break;
        case 'ok' :
            //a command succeeded. We check if it's the one we're
            //waiting for.
            if($curcmdid == $cmdid)
                $success = TRUE;
            break;
        case 'accepted' :
            if((get_int($cmdline, 'usertype') & 2) == 0)
            {
                echo "The user account for login must be an administrator account\r\n";
                exit(1);
            }
            echo "Log in successful!\r\n";
            break;
        case 'loggedin' :
        case 'adduser' :
        case 'updateuser' :
            $id = get_int($cmdline,'userid');
            $users[$id]['userid'] = $id;
            $users[$id]['nickname'] = get_str($cmdline, 'nickname');
            $users[$id]['ipaddr'] = get_str($cmdline, 'ipaddr');
            $channel = get_str($cmdline, 'channel');
            if($channel)
                $users[$id]['channel'] = $channel;
            $username = get_str($cmdline, 'username');
            if($username)
                $users[$id]['username'] = $username;
            break;
        case 'loggedout' :
            $id = get_int($cmdline,'userid');
            unset($users[$id]);
            break;
        case 'removeuser' :
            $id = get_int($cmdline,'userid');
            unset($users[$id]['channel']);
            break;
        case 'addchannel' :
        case 'updatechannel' :
            $channel = get_str($cmdline, 'channel');
            $channels[$channel]['channel'] = $channel;
            $id = get_int($cmdline, 'channelid');
            if($id)
                $channels[$channel]['channelid'] = $id;
            $topic = get_str($cmdline, 'topic');
            if($topic)
                $channels[$channel]['topic'] = $topic;
            $passwd = get_str($cmdline, 'password');
            if($passwd)
                $channels[$channel]['password'] = $passwd;
            $oppasswd = get_str($cmdline, 'oppassword');
            if($oppasswd)
                $channels[$channel]['oppassword'] = $oppasswd;
            $audiocodec = get_list($cmdline, 'audiocodec');
            if($audiocodec)
                $channels[$channel]['audiocodec'] = $audiocodec;
            $audioconfig = get_list($cmdline, 'audiocfg');
            if($audioconfig)
                $channels[$channel]['audioconfig'] = $audioconfig;
            break;
        case 'removechannel' :
            $channel = get_str($cmdline, 'channel');
            unset($channels[$channel]);
            echo "Removed channel $channel\r\n";
            break;
        case 'joined' :
            $channel = get_str($cmdline, 'channel');
            echo "Joined channel $channel\r\n";
            break;
        case 'left' :
            $channel = get_str($cmdline, 'channel');
            echo "Left channel $channel";
            break;
        case 'addfile' :
        case 'removefile' :
            break;
        case 'useraccount' :
            echo $cmdline;
            break;
        case 'userbanned' :
            echo $cmdline;
            break;
        case 'messagedeliver' :
            break;
        case 'stats' :
            $totaltx = get_int($cmdline, 'totaltx');
            $totalrx = get_int($cmdline, 'totalrx');
            $voicetx = get_int($cmdline, 'voicetx');
            $voicerx = get_int($cmdline, 'voicerx');
            $videotx = get_int($cmdline, 'videotx');
            $videorx = get_int($cmdline, 'videorx');
            echo "Server statistics.\r\n";
            echo "Total TX: " . $totaltx / 1024 . " KBytes\r\n";
            echo "Total RX: " . $totalrx / 1024 . " KBytes\r\n";
            echo "Voice TX: " . $voicetx / 1024 . " KBytes\r\n";
            echo "Voice RX: " . $voicerx / 1024 . " KBytes\r\n";
            echo "Video TX: " . $videotx / 1024 . " KBytes\r\n";
            echo "Video RX: " . $videorx / 1024 . " KBytes\r\n";
            break;
        case 'serverupdate' :
            echo "Server updated...\r\n";
            $servername = get_str($cmdline, 'servername');
            echo "Server name is: " . $servername . "\r\n";
            $serverpasswd = get_str($cmdline, 'serverpassword');
            echo "Server password is: $serverpasswd\r\n";
            $maxusers = get_int($cmdline, 'maxusers');
            echo "Max users on server: $maxusers\r\n";
            $usertimeout = get_int($cmdline, 'usertimeout');
            echo "User timeout: $usertimeout seconds\r\n";
            $motd = get_str($cmdline, "motd");
            echo "Server's MOTD is: $motd\r\n";

            $quota_used = get_int($cmdline, 'quotaused');
            $quota_max = get_int($cmdline, 'quotamax');
            if($quota_max)
            {
                echo "Quota set on server: " . $quota_max / (1024*1024) . " MB\r\n";
                echo "Quota used on server: " . $quota_used / (1024*1024) . " MB\r\n";
                $quota_options = TRUE;
            }
            break;
        case 'pong' :
            $success = TRUE;
            break;
        default:
            echo 'Unhandled cmd: ' . $cmdline;
            break;        
        }
        //stop processing now if we're not waiting for a command ID to
        //finish.
        if($cmdid == 0)
            return TRUE;
    }
}

//extract the command line sent by the server (EOL terminates a command)
function get_cmdline($data)
{
    $cmd_regex = '/^([^\r]*\r\n)/';
    if(preg_match($cmd_regex, $data, $matches))
    {
        return $matches[1];
    }
    return FALSE; 
}

//get the command name from a server command
function get_cmd($cmd)
{
    $cmd_regex = '/^(\S+)/';
    if(preg_match($cmd_regex, $cmd, $matches))
    {
        return $matches[1];
    }
    return FALSE; 
}

//get an integer parameter from a server command
function get_int($cmd, $name)
{
    return get_param($cmd, $name);
}

//get a string parameter from a server command
function get_str($cmd, $name)
{
    //example: addchannel channel="/" topic="here a \"quote\" in the topic" 
    $str = get_param($cmd, $name);
    if($str)
    {
        $str = str_replace("\\n", "\n", $str);
        $str = str_replace("\\r", "\r", $str);
        $str = str_replace("\\\"", "\"", $str);
        $str = str_replace("\\\\", "\\", $str);
        $str = utf8_decode($str);
    }
    return $str;
}

//get a set parameter from a server command
function get_list($cmd, $name)
{
    $list = get_param($cmd, $name);
    if($list)
        return explode(",", $list); //not pretty but it works...
    return FALSE;
}

function get_param($cmd, $param)
{
    $CMDNAME = '([a-zA-Z0-9._-]+)';
    $PARAMNAME = '([a-zA-Z0-9._-]+)';
    $DIGIT = '(-?\d+)';
    $STR = '"(([^\\\\^"]+|\\\\n|\\\\r|\\\\"|\\\\\\\\)*)"';
    $LIST = '\[([-?\d+]?[,-?\d+]*)\]';

    $PARAM =  '\s+'.$PARAMNAME.'=('.$LIST.'|'.$DIGIT.'|'.$STR.')';

    $PARAM_STR   =  '\s+'.$PARAMNAME.'='.$STR;
    $PARAM_DIGIT =  '\s+'.$PARAMNAME.'='.$DIGIT;
    $PARAM_LIST  =  '\s+'.$PARAMNAME.'='.$LIST;

    $regex = '/^' . $CMDNAME . '/';
    //strip cmd
    if(!preg_match($regex, $cmd, $matches))
        return FALSE;

    $cmd = substr($cmd, strlen($matches[0]));

    while(strlen($cmd)>0)
    {
        $regex_str   = '/^' . $PARAM_STR . '/';
        $regex_digit = '/^' . $PARAM_DIGIT . '/';
        $regex_list  = '/^' . $PARAM_LIST . '/';

        if(preg_match($regex_str, $cmd, $matches))
        {
        }
        else if(preg_match($regex_digit, $cmd, $matches))
        {
        }
        else if(preg_match($regex_list, $cmd, $matches))
        {
        }
        else return FALSE;

        if($matches[1] == $param)
            return $matches[2];
        else
            $cmd = substr($cmd, strlen($matches[0]));
    }

    return FALSE;    
}

//prepare a string to it can be used in a command to the server
function to_str($str)
{
    $str = utf8_encode($str);
    $str = str_replace("\\", "\\\\", $str);
    $str = str_replace("\"", "\\\"", $str);
    $str = str_replace("\r", "\\r", $str);
    $str = str_replace("\n", "\\n", $str);
    return $str;
}

//get user input from STDIN
function get_userinput($text)
{
    echo $text;
    return trim(fgets(STDIN));
}

//get user input from STDIN and escape it so it can be used in a command to the server
function get_userparam($text)
{
    $str = get_userinput($text);
    return to_str($str); //convert to escaped string parameter
}

//get audio codec for channel
function get_audiocodec()
{
    $audiocodec = get_userinput("Audio codec of new channel (0=No audio, 1=Speex, 2=Speex VBR, 3=CELT, 4=CELT VBR): ");
    switch($audiocodec)
    {
    case 0 :
        $audiocodec = '[0]';
        break;
    case 1 : //Speex
        $audiocodec = '[1,1,4,2,0,0]'; //[Speex CBR codec id, bandmode, quality, frames per packet, jiffer buf enable, simulate stereo]
        break;
    case 2 : //Speex VBR
        $audiocodec = '[4,1,4,0,35000,1,2,0,0]'; //[Speex VBR codec id, bandmode, VBR quality, bitrate, max bitrate, dtx enabled, frames per packet, jitter buf enabled, simulate stereo]
        break;
    case 3: //CELT
        $audiocodec = '[5,44100,1,256,46,7]'; //[CELT codec id, samplerate, channels, frame_size, enc_framesize, frames per packet]
        break;
    case 4 : //CELT VBR
        $audiocodec = '[6,44100,2,64000,256,7]'; //[CELT VBR codec id, samplerate, channels, bitrate, frame size, frames per packet]
        break;
    }
    return $audiocodec;
}

?>
