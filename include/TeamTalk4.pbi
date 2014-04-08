; BearWare.dk TeamTalk 4 SDK.
; *
; Copyright 2005-2014, BearWare.dk.
; *
; Read the License.txt file included with the TeamTalk 4 SDK for
; terms of use.
; */

;*
; @brief Ensure the header and DLL are exactly the same version. To
; get the version of the loaded DLL call TT_GetVersion(). A remote
; client's version can be seen in the @a szVersion member of the
; #User-struct. */
#TEAMTALK4_VERSION = "4.6.0.2927"

;*
; @defgroup initclient Client Initialization
; *
; @brief This section explains how to instantiate a new client
; instance and query its current state.
; *
; #TT_InitTeamTalk takes as parameter a HWND which will have messages
; posted whenever an event in the client instance takes place. These
; are the events defined in #ClientEvent. If the end-user application
; is console-based the function #TT_InitTeamTalkPoll can be used
; where events are processed using #TT_GetMessage.
; *
; When a new client instance is created a call to #TT_GetFlags will
; show that the client initially is in state #CLIENT_CLOSED. This
; means that no operation has been performed on the client.
; *
; Querying #TT_GetFlags call can be used by a user application as a
; state-machine to show which actions are currently possible for the
; user application. The #ClientFlag enumeration shows the information
; which can be retrived though #TT_GetFlags.
; *
; *
; @defgroup sounddevices Sound Capture and Playback
; *
; @brief This section explains how to record and playback audio
; in the client instance.
; *
; Before being able to initialize the sound devices to use for
; recording and playback the computer's available sound devices must
; first be queried. This is done using the functions
; #TT_GetSoundInputDevices and #TT_GetSoundOutputDevices. These two
; functions return arrays of #SoundDevice-structs which contains a
; description of the sound device. In the #SoundDevice-struct there's
; a member variable called @a nDeviceID. This ID should be passed to
; the client instance's two sound initialization functions
; #TT_InitSoundInputDevice and #TT_InitSoundOutputDevice. Once this
; has been done the #TT_GetFlags call will return a value containing
; the mask bits #CLIENT_SNDINPUT_READY and #CLIENT_SNDOUTPUT_READY.
; *
; A computer's default sound devices can be queried using
; #TT_GetDefaultSoundDevices. A loop-back test of the selected sound
; devices can be performed using #TT_StartSoundLoopbackTest.
; 
; Be aware that the sound devices might fail if e.g. a USB sound
; device is unplugged while the client is talking in a channel. In
; this case ensure the application is processing the errors
; #INTERR_SNDINPUT_FAILURE and #INTERR_SNDOUTPUT_FAILURE in the
; #WM_TEAMTALK_INTERNAL_ERROR event.
; *
; Read section @ref transmission to see how to transmit recorded
; audio to other users.
; *
; *
; @defgroup videocapture Video Capture and Image Display
; *
; @brief This section explains how to initialize a video device
; and display captured images on the user's display.
; *
; The client is able to capture video and present them to the user
; application in RGB32-format and transmit the image in encoded
; format to other users.
; *
; @section vidcapinit Initialize Video Capture Device
; *
; @brief This section explains how to detect and configure video
; capture devices.
; *
; To capture video the user application must first query the
; available capture devices by calling #TT_GetVideoCaptureDevices. A
; #VideoCaptureDevice supports a certain number of capture formats
; each described in the @a captureFormats member of #CaptureFormat.
; *
; Once a device has been chosen the #TT_InitVideoCaptureDevice must
; be called for the client instance to start capturing video
; frames. Use the @a szDevice member of #VideoCaptureDevice as the
; device identifier for the video capture device and pass a
; #CaptureFormat from the @a captureFormats array of
; #VideoCaptureDevice. The @a lpVideoCodec parameter of
; #TT_InitVideoCaptureDevice can be passed as NULL if the captured
; video frames do not need to be transmitted. Check out section @ref
; codecs on how to configure the video codec.
; *
; @section vidcapdisplay Display Captured Video
; *
; When a video frame becomes available the event
; #WM_TEAMTALK_USER_VIDEOFRAME is posted to the application and
; #TT_GetUserVideoFrame can be used to extract the RGB32 image. On
; Windows it's also possible to call #TT_PaintVideoFrame to make the
; client instance paint on a HWND by getting its HDC.
; *
; *
; @defgroup codecs Audio and Video Codecs
; *
; @brief This section explains how to configure audio and video
; codecs.
; *
; The client is able to encode audio in Speex and CELT
; format whereas video can be encoded in <a
; href="http://www.theora.org">Theora</a> format. Speex is
; recommended for voice and CELT for music.
; *
; Choosing the right codec settings in an end-user application is
; very important and proper settings depend entirely on the user
; scenario. Always ensure that the codec settings do not require too
; much bandwidth and thereby resulting in packetloss causing
; inaudible conversations and poor video quality. Detecting
; packetloss can be done using #UserStatistics and #ClientStatistics.
; *
; Note that bandwidth usage will be much higher when running in peer
; to peer mode since each client must then broadcast data to all
; users instead of having the server forward the audio and video
; packets. Checkout the section @ref connectivity on the different
; types of connections.
; 
; Every channel must configure which audio codec to use in order for
; users to be able to talk to each other. The @a codec member of
; #Channel specifies which audio codec (#AudioCodec) should be
; used. A channel does not restrict the video codec (#VideoCodec)
; users are using.
; *
; *
; @defgroup desktopshare Desktop Sharing
; *
; @brief This section explains how to use the desktop sharing
; feature where users can share their desktop applications.
; *
; A user can transmit a desktop window to other users in a
; channel by passing the handle of a window to the TeamTalk client
; instance. The TeamTalk client then converts the window to a bitmap
; image which is transmitted to the server. The server then forwards
; the bitmap image to all other users in the channel.
; *
; @section desktoptx Send Desktop Window (or bitmap)
; *
; Before sending a desktop window to a channel the handle
; (identifier) of the window to share must first be found. Windows,
; Mac and Linux (X11) have different ways of locating the window
; handle.
; *
; Instead of using a window handle it's also possible to simply send
; a raw bitmap by calling TT_SendDesktopWindow().
; *
; @subsection desktopwin Windows Desktop Sharing
; *
; TeamTalk for Windows provides the following functions for
; obtaining different @c HWNDs:
; *
; - TT_Windows_GetDesktopActiveHWND()
;   - Get the @c HWND of the window which has focus.
; - TT_Windows_GetDesktopHWND()
;   - Get the @c HWND of the Windows desktop.
; - TT_Windows_GetDesktopWindowHWND()
;   - Enumerate all visible windows.
; - TT_Windows_GetWindow()
;   - Get information about a window, e.g. window title, size, etc.
; *
; Once the @c HWND of the window to share has been found use the
; following function for sending the window to the channel:
; 
; - TT_SendDesktopWindowFromHWND()
; *
; @subsection desktopmac Mac OS Desktop Sharing
; *
; TeamTalk for Mac OS provides the following functions for obtaining
; desktop window handles:
; *
; - TT_MacOS_GetWindow()
;   - Enumerate all active windows.
; - TT_MacOS_GetWindowFromWindowID()
;   - Get information about a window, e.g. window title, size, etc.
; *
; Once the handle (@c CGWindowID) of the window to share has
; been found use the following function for sending the window to the
; channel:
; *
; - TT_SendDesktopFromWindowID()
; *
; @subsection desktopx11 Linux Desktop Sharing
; *
; TeamTalk for Linux does not provide helper functions for getting
; the handle of a X11 window. This is in order to avoid linking the
; TeamTalk DLL to X11. Instead it is recommended to check out @ref
; qtexample which shows how to convert X11 windows to bitmaps and use
; TT_SendDesktopWindow() for transmission.
; 
; @section desktopshow Displaying Shared Desktop Window (or bitmap)
; *
; When a shared desktop window is received the event
; #WM_TEAMTALK_USER_DESKTOPWINDOW is posted to the local client
; instance.  TT_GetUserDesktopWindow() can then be called to obtain
; a bitmap image of the shared window.
; *
; @subsection desktopcursor Desktop Cursor Sharing
; *
; It is also possible to share the position of the mouse cursor when
; sharing a desktop window. Use TT_SendDesktopCursorPosition() to
; transmit the position of the mouse cursor. When the position is
; received the event #WM_TEAMTALK_USER_DESKTOPCURSOR is posted to the
; local client instance. TT_GetUserDesktopCursor() can then be used
; to obtain the cursor position.
; *
; @section desktopinput Remote Desktop Access
; *
; If a user has shared a desktop window it's possible for other users
; in the same channel to take over control of mouse and keyboard on
; the computer sharing the desktop window.
; 
; @subsection rxdesktopinput Receive Desktop Input
; *
; In order for a client instance to allow remote desktop access it is
; required to first subscribe to desktop input from the user who
; wants access to the shared desktop window. This is done by calling
; TT_DoSubscribe() along with the user-id and subscription
; #SUBSCRIBE_DESKTOPINPUT. Once desktop input (mouse or keyboard
; input) is received from a remote user the
; #WM_TEAMTALK_USER_DESKTOPINPUT event will be posted to the client
; instance. The actual mouse or keyboard input can then be obtained
; by the client instance using TT_GetUserDesktopInput() which returns
; a struct of type #DesktopInput. Afterwards
; TT_DesktopInput_Execute() can be used to execute the mouse or
; keyboard input.
; *
; @subsection txdesktopinput Transmit Desktop Input
; 
; The remote user who wants to transmit mouse or keyboard input to
; the user sharing a desktop window can use
; TT_SendDesktopInput(). Remember that the user sharing the desktop
; window must have enabled the subscription #SUBSCRIBE_DESKTOPINPUT.
; *
; @subsection transdesktopinput Desktop Input and Keyboard Layouts
; *
; It can be quite troublesome to handle keyboard input since each
; key-code depends on the OS and the regional settings on the
; OS. E.g. on a German keyboard the Z key is located where the Y key
; is on a US keyboard. The German keyboard also has letters which
; don't even appear on a US keyboard.
; *
; Because of the issues with keyboard layouts and regional settings
; the TeamTalk API provides TT_DesktopInput_KeyTranslate() which can
; be used to translate a keyboard's scan-code to an intermediate
; format. If e.g. a client instance is running Windows then
; TT_DesktopInput_KeyTranslate() can be called with
; #TTKEY_WINKEYCODE_TO_TTKEYCODE which converts the scan-code on a
; Windows keyboard to TeamTalk's intermediate format (TTKEYCODE). To
; be able to execute the key-code once it's received it must be
; converted back again from TeamTalk's intermediate format to the
; platform where the application is running. I.e. if the TTKEYCODE is
; received on a Mac then TT_DesktopInput_KeyTranslate() must be
; called with #TTKEY_TTKEYCODE_TO_MACKEYCODE.
; *
; @defgroup events Client Event Handling
; *
; @brief This section explains how to handle events generated by the
; client instance.
; *
; When events occur in the client instance, like e.g. if a new
; user joins a channel, the client instance queues a message which
; the user application must retrieve.
; *
; If #TT_InitTeamTalk is used with a HWND then the events are sent to
; the user application with WinAPI's PostMessage(...)  function and
; is retrieved through GetMessage(...).
; 
; If a HWND is not used then events can instead be retrieved through
; #TT_GetMessage.
; *
; Note that when an event occurs the TeamTalk client instance doesn't
; wait for the user application to process the event. So if e.g. a
; user sends a text-message and immediately after disconnects from
; the server, then the text-message cannot be retrieved since the
; user is no longer available when the user application starts
; processing the new text-message event. This is, of course, annoying
; when designing the user application, but the reason for this design
; choice it that the client instance is a realtime component which
; cannot wait for the UI to process data, since audio playback and
; recording would then be halted.
; *
; The section @ref stepbystep gives a good idea of how events are
; processed in a user application.
; *
; *
; @defgroup errorhandling Client Error Handling
; *
; @brief This section explains how to handle errors occuring in the
; client instance or as a result of server commands.
; *
; There are two types errors which can occur in the client,
; either server command error or internal errors. Section @ref
; commands describes all the commands a client can issue to a
; server. If a server commands fails the client instance notifies the
; user application through the event #WM_TEAMTALK_CMD_ERROR. An
; example of a server command error could be to issue the #TT_DoLogin
; command with an incorrect server password. The server will in this
; case respond with the error #CMDERR_INCORRECT_SERVER_PASSWORD. The
; user application must be designed to process these errors so
; application users can be notified of errors.
; *
; Internal errors are errors due to failing devices. Currently only
; two such errors exist #INTERR_SNDINPUT_FAILURE and
; #INTERR_SNDOUTPUT_FAILURE.
; *
; *
; @defgroup connectivity Client/Server Connectivity
; *
; @brief This section explains how to connect to a server and how the
; client should transmit voice and video data.
; *
; To communicate with a server the TeamTalk client creates
; both a TCP and UDP connection to the server. Commands, i.e. the
; TT_Do*-functions, are sent on TCP whereas audio and video are sent
; on UDP.
; *
; To connect to a server the user application must call
; #TT_Connect. Once connected the event #WM_TEAMTALK_CON_SUCCESS is
; posted to the user application and the #TT_DoLogin command can be
; issued. Always ensure to call #TT_Disconnect before attempting to
; create a new connection with #TT_Connect.
; *
; When the client instance has joined a channel and wants to transmit
; audio or video data to other users this can be done in two ways
; depending on how the user application configures the client. One
; way is forward through server and the other is peer to peer mode
; which are explained in the following two sections.
; *
; @section txforward Forward Through Server Transmission Mode
; *
; By default the client instance is sending its audio and video
; packets to the server and the server will then broadcast the
; packets to the other users on behalf of the client. In other words
; the client puts the bandwidth load onto the server. This approach
; has its advantages and disadvantages. Since most internet
; connections nowadays have limited upstream they cannot broadcast
; audio and video packets to numerous users at the same time, so
; therefore the default behaviour of the TeamTalk client is to have
; the server do the broadcasting. This means that the server must
; have sufficient bandwidth available to handle data transmission
; from and to all the connected users. One disadvantage by having the
; server forward the audio and video packets is that it doubles
; latency, since the client doesn't send directly to other clients.
; *
; If the server should not allow clients to forward audio and video
; packets the @a uUserRights member of #ServerProperties must disable
; #USERRIGHT_FORWARD_AUDIO and #USERRIGHT_FORWARD_VIDEO. Doing so means
; that clients connecting must use peer to peer connections in order
; to communicate. Note that the client doesn't automatically switch
; to peer to peer mode, but relies on the user application to call
; #TT_EnablePeerToPeer.
; *
; @section txp2p Peer to Peer Transmission Mode
; *
; By calling #TT_EnablePeerToPeer the client instance will attempt to
; create peer to peer connections to all users it's communicating
; with. This reduces latency since the client will then broadcast the
; audio and video packets itself, so they do not have to be forwarded
; through the server.
; *
; The event #WM_TEAMTALK_CON_P2P is posted to the user application if
; a peer to peer connection either fails or succeeds. If a peer to
; peer connection fails the client will send through the server to
; that user given that the server allows it, i.e. if
; #USERRIGHT_FORWARD_AUDIO or #USERRIGHT_FORWARD_VIDEO is enabled.
; *
; If the server does not allow users to forward audio and video
; packets and the peer to peer connection to a user fails, then that
; user will be unavailable for audio and video data. So beware of
; this when configuring the server and client.
; *
; *
; @defgroup commands Client/Server Commands
; *
; @brief This section contains the list of commands which can be
; issued by the client instance to the server.
; *
; @section cmdprocessing Client/Server Command Processing
; *
; Functions with the prefix TT_Do* are commands which the client can
; issue to the server. Every TT_Do* function returns a command
; identifier which can user application can use to check when the
; server has finished processing the issued command. Once the client
; receives a response to a command the client instance posts the
; event #WM_TEAMTALK_CMD_PROCESSING to the user application
; containing the command identifier and whether the command is being
; processed or it has completed.
; *
; As an example, say the user application wants to issue the
; #TT_DoLogin command. When the application calls #TT_DoLogin the
; returned command ID is stored in a variable. The application then
; waits for the #WM_TEAMTALK_CMD_PROCESSING event to be posted with
; the stored command ID. The first time #WM_TEAMTALK_CMD_PROCESSING
; is posted to the user application it is to say that processing has
; begun. The second time #WM_TEAMTALK_CMD_PROCESSING is called it is
; to say that the command has completed. In between the command
; starting and completing several other events may take place. If
; e.g. the #TT_DoLogin fails the user application would receive the
; event #WM_TEAMTALK_CMD_ERROR. If on the other hand the command was
; successful all the channels and user would be posted as events to
; the application before the login-command completed processing.
; *
; *
; @defgroup transmission Audio and Video Transmission
; *
; @brief This section explains how to transmit audio and video to
; users in a channel.
; *
; Once the client instance has joined a channel it can
; transmit audio and video to other users in the channel. When
; transmitting audio and video it is important to be aware of how the
; client is configured to do this. Sections @ref txforward and @ref
; txp2p explains the two supported data transmission modes.
; *
; To transmit audio the client must have the flag
; #CLIENT_SNDINPUT_READY enabled which is done in the function
; #TT_InitSoundInputDevice. To transmit video requires the flag
; #CLIENT_VIDEO_READY which is enabled by the function
; #TT_InitVideoCaptureDevice. To hear what others users are saying a
; sound output device must have been configured using
; #TT_InitSoundOutputDevice and thereby have enabled the flag
; #CLIENT_SNDOUTPUT_READY.
; *
; Calling #TT_EnableTransmission will make the client instance start
; transmitting either audio or video data. Note that audio
; transmission can also be activated automatically using voice
; activation. This is done by called #TT_EnableVoiceActivation and
; setting a voice activation level using #TT_SetVoiceActivationLevel.
; *
; *
; @defgroup server Server Properties
; *
; @brief This section explains how to configure a server and setup
; user accounts.
; *
; The server keeps track of which users are in which channels
; and ensures that users in the same channel can communicate with
; each other. It is also the job of the server to provide user
; authentication so only users with the proper credentials are
; allowed to do certain operations.
; *
; It is a good idea to check out section @ref serversetup to learn
; how to configure the TeamTalk server.
; *
; The server can be configured in a number of ways using the
; #ServerProperties-struct. Only users who are logged on to the
; server as administrators can change a server's properties while
; it's running. This is done using the command #TT_DoUpdateServer.
; *
; The @a uUserRights bitmask in #ServerProperties specifies what
; users are allowed to do. The server can e.g. be configured to only
; allow users who have an account to log on by disabling the flag
; #USERRIGHT_GUEST_LOGIN. If default users (without administrator
; rights) shouldn't be allowed to create channels this can be
; disabled by disabling the flag #USERRIGHT_CHANNEL_CREATION.
; *
; @section useradmin User Administration
; *
; Two types of users exists on a server, default users and
; administrator users. The #UserType-enum can be used to see who is
; what. To be administrator the user must have a user account on the
; server with the #USERTYPE_ADMIN flag set.
; *
; As administrator it is possible to list all users who have an
; account on the server using #TT_DoListUserAccounts. To create a new
; user account call the command #TT_DoNewUserAccount and to delete an
; account call #TT_DoDeleteUserAccount.
; *
; @section userban Kicking and Banning Users
; *
; Sometimes it may be necessary to kick and ban users from a
; server. As administrator it is possible to use the command
; #TT_DoKickUser to kick a user off the server. A channel operator
; can also kick a user from a channel (but not off a server).
; *
; As administrator it is also possible to ban users from the server,
; so they can no longer log in. This can be done using
; #TT_DoBanUser. To list who are currently banned call #TT_DoListBans
; and to remove a ban call #TT_DoUnBanUser.
; *
; *
; @defgroup channels Channel Properties
; *
; @brief This section explains the concept of channels where users
; can interact.
; *
; Users are arranged in a tree structure consisting of
; channels where each channel can hold a number of users. While
; in a channel users can transmit audio and video to each other
; as well as sending channel messages. On a server there will
; always be a root channel which cannot be deleted.
; *
; In other conferencing tools channels are also refered to as
; "rooms".
; *
; @section chanadmin Channel Administration
; *
; To create a new channel on a server an administrator can call
; #TT_DoMakeChannel whereas a default user (without administrator
; rights) has to use #TT_DoJoinChannel to create a new channel. Using
; #TT_DoJoinChannel creates a dynamic channel which disappears again
; from the server when the last user leaves the channel. The first
; user to join a dynamic channel will become operator of the channel,
; meaning that he can kick user and make other operators as well.
; *
; Updating a channel's properties can only be done by administrators
; and operators of the channel and this is done by using
; #TT_DoUpdateChannel.
; *
; To remove a channel a user must be administrator and can do so by
; calling #TT_DoRemoveChannel.
; 
; @section filesharing File Sharing
; *
; While in a channel users can upload and download files. To upload a
; file to a channel the channel needs to have a disk quota. The disk
; quota is specified by @a nDiskQuota in the #Channel-struct. The
; file being uploaded must have a file size which is less than the
; disk quota and the sum of sizes of existing files. Once a file is
; uploaded only administrators, channel operators and the file's
; owner can delete a file. Note that the file's owner must have an
; account on the server to delete the file.
; *
; Call #TT_DoSendFile to upload a file and #TT_DoRecvFile to download
; a file. Only users who have a #UserAccount on the server are
; allowed to upload files. There is no limit on the maximum number of
; file transfers but it is advised to queue file transfers so the
; file transfers do no affect server performance.
; *
; @section voicelog Storing Conversations to Audio Files
; *
; In some applications it may be required to be able to save all
; audio data received by the client instance to disk. This can be
; archived by calling #TT_SetUserAudioFolder which will then save
; received audio data in the following format: "YYYYMMDD-HHMMSS
; \#USERID USERNAME.wav". USERNAME is the @a szUsername from #User.
; *
; To store audio data from outside the local client instance's
; channel, please read section @ref spying.
; *
; *
; @defgroup users User Properties
; *
; @brief This section explains users interact and how to configure
; user settings.
; *
; Users can be seen on the server after a successful call
; to #TT_DoLogin. Once logged in a user can send user to user
; text-messages using #TT_DoTextMessage as well as receive
; broadcast messages. A user cannot send audio and video data to
; other users until they have joined the same channel.
; *
; @section usertypes User Types
; *
; A user can either be a default user #USERTYPE_DEFAULT or an
; administrator #USERTYPE_ADMIN. A default user has limited rights on the
; server whereas an administrator can change server properties,
; create, delete and remove channels as well as move, kick and ban
; users.
; *
; @section userinteract User Interaction
; *
; Once a user has joined a channel it is possible to transmit audio
; and video data to other users. If a user starts talking in the
; channel the event #WM_TEAMTALK_USER_TALKING is posted to the user
; application and if a video frame is received the event
; #WM_TEAMTALK_USER_VIDEOFRAME is sent to the user application.
; *
; @section uservolume User Audio Settings
; *
; While in the same channel the user application can change different
; settings on a user. If e.g. a user's volume is too low the user
; application can call #TT_SetUserVolume to increase the volume. If
; it's still not loud enough #TT_SetUserGainLevel can be called to
; use software to amplify the volume level.
; *
; If on the other hand the user application wants to mute a user
; #TT_SetUserMute can be used for this. Note that muting a user
; doesn't mean that the client instance will stop receiving audio
; from that user, it simply means it will not be played. To stop
; receiving audio from a user the local client instance must ask the
; server to unsubscribe audio data from the user. This is explained
; in the next section.
; *
; @section subscriptions User Subscriptions
; 
; When logging on to a server the local client instance will by
; default subscribe to user messages, channel messages, broadcast
; messages, audio data and video data from all users. If, however, a
; client wants to stop receiving e.g. audio from a user, he can call
; #TT_DoUnsubscribe along with the user ID and the
; #SUBSCRIBE_AUDIO-flag to tell the server that he no longer wants to
; receive audio from that user. The server will then respond with the
; event #WM_TEAMTALK_CMD_USER_UPDATE and the @a uLocalSubscriptions
; member of #User will have the #SUBSCRIBE_AUDIO-flag removed. At the
; remote user the \a uPeerSubscriptions member will be
; changed. Subscribe/unsubscribe can also be done for user, channel
; and broadcast messages and video data. The function #TT_DoSubscribe
; can be used to revert unsubscriptions.
; *
; @subsection spying Spying on Users
; *
; Previously it has been said that users can only receive audio and
; video from users when they are in the same channel, but actually an
; administrator user can call #TT_DoSubscribe with the flags prefixed
; SUBSCRIBE_INTERCEPT_* to spy on users outside his own channel. In
; other words it's possible hear and see video data outside ones
; channel. Also all user and channel messages sent by a user can also
; be intercepted in this way.
; *
; Having the ability to intercept all data sent from users in any
; channel means that it's possible to log everything that is
; happening on the server. Both audio and video transfers as well as
; text messaging. Checkout #TT_SetUserAudioFolder on how to store
; voice data to audio files.
; *
; *
; @defgroup hotkey Windows Hotkeys
; *
; @brief This section explains how to setup hot-keys on Windows.
; *
; Hotkeys can be used to e.g. enable push-to-talk.
; *
; Windows supports intercepting key strokes globally, i.e. without
; having the user application's window focused. To investigate which
; keys are currently being pressed the function
; #TT_HotKey_InstallTestHook can be used. Once the desired
; key-combination has been found the function #TT_HotKey_Register can
; be used to register the combination as a hotkey and have the
; #WM_TEAMTALK_HOTKEY event posted whenever the key combination
; becomes active.
; *
; Note that it's not advised to have a hotkey installed while
; debugging an application in Visual Studio. It slows down the
; debugger dramatically.
; 
; *
; @defgroup mixer Windows Mixer
; *
; @brief This section explains how to control the Windows mixer.
; *
; The Windows mixer can be manipulated so e.g. Line In can be
; chosen instead of Microphone for recording.
; *
; To find the mixer which is associated with the current sound input
; or output device the @a nWaveDeviceID member of #SoundDevice must
; be used when querying the mixer.
; *
; @defgroup firewall Windows Firewall
; *
; @brief This section explains how to configure the Windows firewall
; available in Windows XP SP2 and later.
; *
; The Windows Firewall can be modified so applications can be
; added to the firewall's exception list.
; *
; The Windows Firewall was introduced in Windows XP SP2. Modifying
; the Windows Firewall requires administrator rights. On Windows XP
; the user running the application, which calls the DLL, is assumed
; to have administrator rights. On Windows Vista/7 the DLL will
; automatically call User Account Control (UAC) to obtain
; administrator rights.
; *
; Check out TT_Firewall_AddAppException() on how to add application
; executables to the Windows Firewall exception list.
; *
; */


    ; OS specific types. */
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
;* @brief Linux doesn't have WM_USER defined so set it to 0. It is
; used as an initial value for #ClientEvent. */
#WM_USER = 0
CompilerEndIf

;* @ingroup initclient
   ;  *
     ; @brief Pointer To a TeamTalk client instance created by
     ; #TT_InitTeamTalk. @see TT_CloseTeamTalk */
    ; typedef VOID TTInstance;

    ;* @addtogroup events
     ; @{ */

    ;* 
     ; @brief TeamTalk client event messages. On Windows these
     ; messages are posted To the HWND which was provided To
     ; #TT_InitTeamTalk
   ; */
    Enumeration ClientEvent
        ;* @brief Ignore this message. It can be used in applications
         ; To filter messages related To TeamTalk And internal
         ; messages */
        #WM_TEAMTALK_DUMMY_FIRST = #WM_USER + 449

        ;*
         ; @brief Connected successfully To the server.
       ;  *
         ; This event is posted If #TT_Connect was successful.
       ; *
         ; #TT_DoLogin can now be called in order To logon To the
         ; server.
       ; *
         ; @param wParam Ignored
         ; @param lParam Ignored
         ; @see TT_Connect
         ; @see TT_DoLogin */
        #WM_TEAMTALK_CON_SUCCESS ; WM_USER + 450 */

        ;* 
         ; @brief Failed To connect To server.
;   ;    *
         ; This event is posted If #TT_Connect fails. Ensure To call
         ; #TT_Disconnect before calling #TT_Connect again.
;   ;    *
         ; @param wParam Ignored
         ; @param lParam Ignored
         ; @see TT_Connect */
        #WM_TEAMTALK_CON_FAILED

        ;* 
         ; @brief Connection To server has been lost.
;   ;    *
         ; The server is Not responding To requests from the local
         ; client instance And the connection has been dropped. To
         ; change when the client instance should regard the server As
         ; unavailable call #TT_SetServerTimeout. 
;   ;    *
         ; #TT_GetStatistics can be used To check when Data was
         ; last received from the server.
;   ;    *
         ; Ensure To call #TT_Disconnect before calling #TT_Connect
         ; again.
;   ;    *
         ; @param wParam Ignored
         ; @param lParam Ignored
         ; @see TT_Connect */
        #WM_TEAMTALK_CON_LOST

        ;* 
         ; @brief Peer To peer (p2p) status changed.
;   ;    *
         ; Audio And video packets can be sent To the user without
         ; forwarding through the server. This is done by enabling P2P
         ; network using #TT_EnablePeerToPeer. Once the client instance
         ; joins a new channel it will try And create a peer To peer
         ; connection To each user in the channel. The client instance
         ; will try To create a peer To peer connection For 5 seconds.
;   ;    *
         ; Read section @ref txforward And section @ref txp2p on the
         ; different ways of transmitting Data.
;   ;    *
         ; @param wParam User ID
         ; @param lParam TRUE If P2P connection was successful, FALSE If P2P
         ; connection failed.
         ; @see USERRIGHT_FORWARD_AUDIO
         ; @see USERRIGHT_FORWARD_VIDEO */
        #WM_TEAMTALK_CON_P2P

        ;* 
         ; @brief A command issued by @c TT_Do* methods is being
         ; processed.
;   ;    *
         ; Read section @ref cmdprocessing on how To use command
         ; processing in the user application.
;   ;    *
         ; @param wParam Command ID being processed (returned by TT_Do* 
         ; commands)
         ; @param lParam Is 0 If command ID started processing And 1
         ; If the command has finished processing. */
        #WM_TEAMTALK_CMD_PROCESSING

        ;* 
         ; @brief The client instance successfully logged on To
         ; server.
;   ;    *
         ; The call To #TT_DoLogin was successful And all channels on
         ; the server will be posted in the event
         ; #WM_TEAMTALK_CMD_CHANNEL_NEW immediately following this
         ; event. If #USERRIGHT_VIEW_ALL_USERS is enabled the client
         ; instance will also receive the events
         ; #WM_TEAMTALK_CMD_USER_LOGGEDIN And
         ; #WM_TEAMTALK_CMD_USER_JOINED For every user on the server.
;   ;    *
         ; @param wParam The client instance's user ID, i.e. what can now 
         ; be retrieved through #TT_GetMyUserID.
         ; @param lParam Ignored
         ; @see TT_DoLogin */
        #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN

        ;* 
         ; @brief The client instance logged out of a server.  
;   ;    *
         ; A response To #TT_DoLogout.
;   ;    *
         ; @param wParam Ignored
         ; @param lParam Ignored
         ; @see TT_DoLogout */
        #WM_TEAMTALK_CMD_MYSELF_LOGGEDOUT

        ;* 
         ; @brief The client instance has joined a new channel. 
;   ;    *
         ; Result of command #TT_DoJoinChannel Or
         ; #TT_DoJoinChannelByID. Can also be a result of an
         ; administrator calling #TT_DoMoveUser.
;   ;    *
         ; If #USERRIGHT_VIEW_ALL_USERS is disabled the client instance
         ; will afterwards receive the #WM_TEAMTALK_CMD_USER_JOINED
         ; event For each of the users in the channel.
;   ;    *
         ; @param wParam Channel's ID
         ; @param lParam Ignored
         ; @see WM_TEAMTALK_CMD_MYSELF_LEFT */
        #WM_TEAMTALK_CMD_MYSELF_JOINED

        ;* 
         ; @brief The client instance left a channel. 
;   ;    *
         ; The WPARAM contains the channel ID. 
;   ;    *
         ; @param wParam Channel's ID
         ; @param lParam Ignored
         ; @see TT_DoLeaveChannel
         ; @see WM_TEAMTALK_CMD_MYSELF_JOINED */
        #WM_TEAMTALK_CMD_MYSELF_LEFT

        ;* 
         ; @brief The client instance was kicked from a channel.
;   ;    *
         ; @param wParam User ID of the kicker.
         ; @param lParam Ignored */
        #WM_TEAMTALK_CMD_MYSELF_KICKED

        ;*
         ; @brief A new user logged on To the server.
;   ;    *
         ; Use #TT_GetUser To get the properties of the user.
;   ;    *
         ; @param wParam The user's ID.
         ; @param lParam Unused
         ; @see TT_DoLogin
         ; @see TT_GetUser To retrieve user.
         ; @see WM_TEAMTALK_CMD_USER_LOGGEDOUT */
        #WM_TEAMTALK_CMD_USER_LOGGEDIN

        ;*
         ; @brief A client logged out of the server. 
;   ;    *
         ; This event is called when a user logs out With
         ; #TT_DoLogout Or disconnects With #TT_Disconnect.
;   ;    *
         ; @param wParam The user's ID.
         ; @param lParam Unused
         ; @see TT_DoLogout
         ; @see TT_Disconnect
         ; @see WM_TEAMTALK_CMD_USER_LOGGEDIN */
        #WM_TEAMTALK_CMD_USER_LOGGEDOUT

        ;*
         ; @brief User changed properties.
;   ;    *
         ; Use #TT_GetUser To see the new properties.
;   ;    *
         ; @param wParam User's ID
         ; @param lParam Channel ID. 0 For no channel.
         ; @see TT_GetUser To retrieve user. */
        #WM_TEAMTALK_CMD_USER_UPDATE

        ;* 
         ; @brief A user has joined a channel.
;   ;    *
         ; @param wParam User's ID.
         ; @param lParam Channel ID.
         ; @see TT_GetUser To retrieve user. */
        #WM_TEAMTALK_CMD_USER_JOINED

        ;* 
         ; @brief User has left a channel.
;   ;    *
         ; @param wParam User's ID.
         ; @param lParam Channel ID. */
        #WM_TEAMTALK_CMD_USER_LEFT

        ;* 
         ; @brief A user has sent a text-message.
;   ;    *
         ; @param wParam The user's user ID.
         ; @param lParam The message's ID. 
         ; @see TT_GetTextMessage To retrieve text message.
         ; @see TT_GetUser To retrieve user.
         ; @see TT_DoTextMessage() To send text message. */
        #WM_TEAMTALK_CMD_USER_TEXTMSG

        ;* 
         ; @brief A new channel has been created.
;   ;    *
         ; @param wParam Channel's ID
         ; @param lParam Ignored
         ; @see TT_GetChannel To retrieve channel. */
        #WM_TEAMTALK_CMD_CHANNEL_NEW

        ;* 
         ; @brief A channel's properties has been updated.
;   ;    *
         ; wParam Channel's ID
         ; lParam Ignored
         ; @see TT_GetChannel To retrieve channel. */
        #WM_TEAMTALK_CMD_CHANNEL_UPDATE

        ;* 
         ; @brief A channel has been removed.
;   ;    *
         ; Note that calling the #TT_GetChannel With the channel ID
         ; will fail because the channel is no longer there.
;   ;    *
         ; @param wParam Channel's ID
         ; @param lParam Ignored */
        #WM_TEAMTALK_CMD_CHANNEL_REMOVE

        ;* 
         ; @brief Server has updated its settings (server name, MOTD,
         ; etc.)
         ; 
         ; Use #TT_GetServerProperties To get the new server
         ; properties.
;   ;    *
         ; @param wParam Ignored
         ; @param lParam Ignored */
        #WM_TEAMTALK_CMD_SERVER_UPDATE

        ;* 
         ; @brief A new file is added To a channel. 
;   ;    *
         ; Use #TT_GetChannelFileInfo To get information about the
         ; file.
;   ;    *
         ; @param wParam File ID.
         ; @param lParam Channel ID.
         ; @see TT_GetChannelFileInfo To retrieve file. */
        #WM_TEAMTALK_CMD_FILE_NEW

        ;* 
         ; @brief A file has been removed from a channel.
;   ;    *
         ; @param wParam File ID. 
         ; @param lParam Channel ID. */
        #WM_TEAMTALK_CMD_FILE_REMOVE

        ;* 
         ; @brief The server rejected a command issued by the local
         ; client instance.
;   ;    *
         ; To figure out which command failed use the command ID
         ; returned by the TT_Do* command. Section @ref cmdprocessing
         ; explains how To use command ID.
;   ;    *
         ; @param wParam Error number
         ; @param lParam The command ID returned from the TT_Do* commands.
         ; @see TT_GetErrorMessage */
        #WM_TEAMTALK_CMD_ERROR

        ;*
         ; @brief The server successfully processed  a command issued by the local
         ; client instance.
;   ;    *
         ; To figure out which command succeeded use the command ID
         ; returned by the TT_Do* command. Section @ref cmdprocessing
         ; explains how To use command ID.
;   ;    *
         ; @param wParam The command ID returned from the TT_Do* commands.
         ; @param lParam 0. */
        #WM_TEAMTALK_CMD_SUCCESS

        ;*
         ; @brief A user is talking.
;   ;    *
         ; Playback using the sound output device has started For a
         ; user.
;   ;    *
         ; @param wParam User's ID.
         ; @param lParam TRUE If talking otherwise FALSE.
         ; @see TT_GetUser To retrieve user.
         ; @see TT_IsTransmitting To see If 'myself' is transmitting.
         ; @see TT_SetUserStoppedTalkingDelay */
        #WM_TEAMTALK_USER_TALKING

        ;* 
         ; @brief A new video frame was received from a user.
;   ;    *
         ; Use #TT_GetUserVideoFrame To display the image.
;   ;    *
         ; @param wParam User's ID.
         ; @param lParam Number of video frames currently in queue For
         ; display. The client uses a cyclic buffer For video frame in
         ; order To prevent resources from being drained. Therefore
         ; the #WM_TEAMTALK_USER_VIDEOFRAME event might be posted
         ; more times than there actually are frames available. So use
         ; the frame count To ensure the lastest frame is always
         ; displayed. */
        #WM_TEAMTALK_USER_VIDEOFRAME

        ;* 
         ; @brief An audio file recording has changed status.
;   ;    *
         ; #TT_SetUserAudioFolder makes the client instance store all
         ; audio from a user To a specified folder. Every time an
         ; audio file is being processed this event is posted.
;   ;    *
         ; @param wParam The user's ID.
         ; @param lParam The status of the audio file. Based on
         ; #AudioFileStatus. */
        #WM_TEAMTALK_USER_AUDIOFILE

        ;* 
         ; @brief A sound device failed To initialize. 
;   ;    *
         ; This can e.g. happen If a new user joins a channel And
         ; there is no sound output channels
         ; available. nMaxOutputChannels of #SoundDevice struct tells
         ; how many streams can be active simultaneously.
;   ;    *
         ; @param wParam An error number based on #ClientError. The value
         ; will be of the type @c INTERR_*.
         ; @see WM_TEAMTALK_CMD_MYSELF_JOINED If sound input device fails it
         ; will be when joining a new channel.
         ; @see TT_GetSoundOutputDevices
         ; @see SoundDevice */
        #WM_TEAMTALK_INTERNAL_ERROR

        ;* 
         ; @brief Voice activation has triggered transmission.
;   ;    *
         ; @param wParam TRUE If enabled, FALSE If disabled.
         ; @param lParam Unused
         ; @see TT_SetVoiceActivationLevel
         ; @see CLIENT_SNDINPUT_VOICEACTIVATION
         ; @see TT_EnableTransmission */
        #WM_TEAMTALK_VOICE_ACTIVATION

        ;* 
         ; @brief An audio file being streamed To a user is
         ; processing.
;   ;    *
         ; This event is called As a result of
         ; #TT_StartStreamingAudioFileToUser.
;   ;    *
         ; @param wParam User's ID of where the audio file is streamed to.
         ; @param lParam The status of the audio file. Based on #AudioFileStatus
         ; @see TT_StartStreamingAudioFileToUser */
        #WM_TEAMTALK_STREAM_AUDIOFILE_USER

        ;* 
         ; @brief Audio file being stream To a channel is processing.
;   ;    *
         ; This event is called As a result of
         ; #TT_StartStreamingAudioFileToChannel.
;   ;    *
         ; @param wParam Channel's ID of where the audio file is being 
         ; streamed To.
         ; @param lParam The status of the audio file. Based on
         ; #AudioFileStatus.
         ; @see TT_StartStreamingAudioFileToChannel */
        #WM_TEAMTALK_STREAM_AUDIOFILE_CHANNEL

        ;* 
         ; @brief A hotkey has been acticated Or deactivated.
;   ;    *
         ; @param wParam The hotkey ID passed To #TT_HotKey_Register
         ; @param lParam is TRUE when hotkey is active And FALSE when 
         ; it becomes inactive.
         ; @see TT_HotKey_Register
         ; @see TT_HotKey_Unregister */
        #WM_TEAMTALK_HOTKEY

        ;*
         ; @brief A button was pressed Or released on the user's
         ; keyboard Or mouse.
         ; 
         ; When #TT_HotKey_InstallTestHook is called a hook is
         ; installed in Windows which intercepts all keyboard And
         ; mouse presses. Every time a key Or mouse is pressed Or
         ; released this event is posted.
;   ;    *
         ; Use #TT_HotKey_GetKeyString To get a key description of the 
         ; pressed key.
;   ;    *
         ; @param wParam The virtual key code. Look here For a List of virtual
         ; key codes: http://msdn.microsoft.com/en-us/library/ms645540(VS.85).aspx
         ; @param lParam TRUE when key is down And FALSE when released. 
         ; @see TT_HotKey_InstallTestHook */
        #WM_TEAMTALK_HOTKEY_TEST

        ;*
         ; @brief A file transfer is processing. 
;   ;    *
         ; Use #TT_GetFileTransferInfo To get information about the
         ; file transfer. Ensure To check If the file transfer is
         ; completed, because the file transfer instance will be
         ; removed from the client instance when the user application
         ; reads the #FileTransfer object And it has completed the
         ; transfer.
;   ;    *
         ; @param wParam Transfer ID
         ; @param lParam The #FileTransfer's status described by 
         ; #FileTransferStatus.
         ; @see TT_GetFileTransferInfo To retrieve #FileTransfer. */
        #WM_TEAMTALK_FILETRANSFER

        ;*
         ; @brief A new audio block can be extracted.
;   ;    *
         ; This event is only generated If TT_EnableAudioBlockEvent()
         ; is first called.
;   ;    *
         ; Call TT_AcquireUserAudioBlock() To extract the #AudioBlock.
;   ;    *
         ; @param wParam The user ID.
         ; @param lParam Unused. */
        #WM_TEAMTALK_USER_AUDIOBLOCK

        ;*
         ; @brief A new Or updated desktop window has been received
         ; from a user.
;   ;    *
         ; Use TT_GetUserDesktopWindow() To retrieve the bitmap of the
         ; desktop window.
;   ;    *
         ; @param wParam The user's ID.
         ; @param lParam The ID of the desktop window's session. If
         ; this ID changes it means the user has started a new
         ; session. If the session ID becomes 0 it means the desktop
         ; session has been closed by the user.
         ; @see TT_SendDesktopWindow() */
        #WM_TEAMTALK_USER_DESKTOPWINDOW

        ;*
         ; @brief Used For tracking when a desktop window has been
         ; transmitted To the server.
;   ;    *
         ; When the transmission has completed the flag #CLIENT_TX_DESKTOP
         ; will be cleared from the local client instance.
;   ;    *
         ; @param wParam The desktop session's ID. If the desktop session ID
         ; becomes 0 it means the desktop session has been closed And/Or
         ; cancelled.
         ; @param lParam The number of bytes remaining before transmission
         ; of last desktop window completes. When remaining bytes is 0 
         ; TT_SendDesktopWindow() can be called again. */
        #WM_TEAMTALK_DESKTOPWINDOW_TRANSFER

        ;*
         ; @brief A user has sent the position of the mouse cursor.
;   ;    *
         ; Use TT_SendDesktopCursorPosition() To send the position of
         ; the mouse cursor.
;   ;    *
         ; @param wParam The user ID of the owner of the mouse cursor.
         ; @param lParam The owner of the desktop session the mouse cursor
         ; is pointing To. */
        #WM_TEAMTALK_USER_DESKTOPCURSOR

        ;*
         ; @brief The maximum size of the payload put into UDP packets
         ; has been updated.
;   ;    *
         ; @param wParam The user's ID. 0 means server's maximum payload
         ; size.
         ; @param lParam The maximum size in bytes of the payload Data which
         ; is put in UDP packets. 0 means the max payload query failed.
         ; @see TT_QueryMaxPayload() */
        #WM_TEAMTALK_CON_MAX_PAYLOAD_UPDATED

        ;* 
         ; @brief Media file being streamed To a channel is processing.
;   ;    *
         ; This event is called As a result of
         ; TT_StartStreamingMediaFileToChannel().
;   ;    *
         ; @param wParam Unused.
         ; @param lParam The status of the audio file. Based on
         ; #AudioFileStatus. */
        #WM_TEAMTALK_STREAM_MEDIAFILE_CHANNEL

        ;*
         ; @brief Desktop Input (mouse Or keyboard input) has been
         ; received from a user.
;   ;    *
         ; This event is generated If a remote user has called
         ; TT_SendDesktopInput(). In order For the local client
         ; instance To received desktop input it must have enabled the
         ; subscription #SUBSCRIBE_DESKTOPINPUT.
;   ;    *
         ; Call TT_GetUserDesktopInput() To obtain the mouse Or
         ; keyboard key-codes.
;   ;    *
         ; @param wParam User ID
         ; @param lParam Unused.
;   ;    */
        #WM_TEAMTALK_USER_DESKTOPINPUT
      EndEnumeration
      
    ;*
     ; @brief A struct containing the properties of an event.
;;    *
     ; The event can be retrieved by called #TT_GetMessage. This
     ; struct is only required on non-Windows systems.
;    *
     ; Section @ref events explains event handling in the local client
     ; instance.
;    *
     ; @see TT_GetMessage */
     ; (Unfortunately PB does not have native support for UInt32, thus a Quad adds some overhead)
     Structure TTMessage
        ;* @brief The event's message number @see ClientEvent */
        wmMsg.w ; the value is a member of ClientEvent
        ;* @brief The first message parameter */
         wParam.q
        ;* @brief The second message parameter */
        lParam.q
EndStructure

;* @}*/

    ;* @def TT_STRLEN
     ; extract information from this DLL. 
;    *
     ; If a string is passed To the client instance is longer than
     ; TT_STRLEN it will be truncated.
;    *
     ; On Windows the client instance converts unicode characters To
     ; UTF-8 before transmission, so be aware of non-ASCII characters
     ; If communicating With the TeamTalk server from another
     ; applications than the TeamTalk client. */
#TT_STRLEN = 512

    ;* @ingroup videocapture
     ; @def TT_CAPTUREFORMATS_MAX
     ; The maximum number of video formats which will be queried For a 
     ; #VideoCaptureDevice. */
#TT_CAPTUREFORMATS_MAX = 128

    ;* @ingroup channels
     ; @def TT_VOICEUSERS_MAX
     ; The maximum number of users allowed To transmit audio when a
     ; #Channel is configured With #CHANNEL_CLASSROOM. */
#TT_VOICEUSERS_MAX = 16

    ;* @ingroup channels
     ; @def TT_VIDEOUSERS_MAX
     ; The maximum number of users allowed To transmit video when a
     ; #Channel is configured With #CHANNEL_CLASSROOM. */
#TT_VIDEOUSERS_MAX = 16

    ;* @ingroup channels
     ; @def TT_DESKTOPUSERS_MAX
     ; The maximum number of users allowed To transmit when a #Channel
     ; is configured With #CHANNEL_CLASSROOM. */
#TT_DESKTOPUSERS_MAX = 16

    ;* @ingroup channels
     ; @def TT_CLASSROOM_FREEFORALL
     ; If a #Channel is configured With #CHANNEL_CLASSROOM then only users
     ; certain user IDs are allowed To transmit. If, however, @c 
     ; TT_CLASSROOM_FREEFORALL is put in either @c voiceUsers, @c videoUsers 
     ; And @c desktopUsers then everyone in the channel are allowed To 
     ; transmit. */
#TT_CLASSROOM_FREEFORALL = $FFFF

    ;* @ingroup users
     ; @def TT_CHANNELS_OPERATOR_MAX
     ; The maximum number of channels where a user can automatically become
     ; channel operator.
     ; @see #UserAccount */
#TT_CHANNELS_OPERATOR_MAX = 16

    ;* @ingroup sounddevices
     ; The maximum number of sample rates supported by a #SoundDevice. */
#TT_SAMPLERATES_MAX = 16

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_MAX
; *
; The maximum number #DesktopInput instances which can be sent by
; TT_SendDesktopInput() or received by TT_GetUserDesktopInput() */
#TT_DESKTOPINPUT_MAX = 16

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_KEYCODE_IGNORE
; *
; If @c uKeyCode in #DesktopInput is set to
; #TT_DESKTOPINPUT_KEYCODE_IGNORE it means no key (or mouse button)
; was pressed in the desktop input event and
; TT_DesktopInput_Execute() will ignore the value. */
#TT_DESKTOPINPUT_KEYCODE_IGNORE = $FFFFFFFF

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_MOUSEPOS_IGNORE
; *
; If @c uMousePosX or @c uMousePosY in #DesktopInput are set to
; #TT_DESKTOPINPUT_MOUSEPOS_IGNORE it means the mouse position is
; ignored when calling TT_DesktopInput_Execute(). */
#TT_DESKTOPINPUT_MOUSEPOS_IGNORE = $FFFF

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_KEYCODE_LMOUSEBTN
; *
; If @c uKeyCode of #DesktopInput is set to
; #TT_DESKTOPINPUT_KEYCODE_LMOUSEBTN then TT_DesktopInput_Execute()
; will see the key-code as a left mouse button click. */
#TT_DESKTOPINPUT_KEYCODE_LMOUSEBTN = $1000

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_KEYCODE_RMOUSEBTN
; *
; If @c uKeyCode of #DesktopInput is set to
; #TT_DESKTOPINPUT_KEYCODE_RMOUSEBTN then TT_DesktopInput_Execute()
; will see the key-code as a right mouse button click. */
#TT_DESKTOPINPUT_KEYCODE_RMOUSEBTN = $1001

;* @ingroup desktopshare
; @def TT_DESKTOPINPUT_KEYCODE_MMOUSEBTN
; *
; If @c uKeyCode of #DesktopInput is set to
; #TT_DESKTOPINPUT_KEYCODE_MMOUSEBTN then TT_DesktopInput_Execute()
; will see the key-code as a middle mouse button click. */
#TT_DESKTOPINPUT_KEYCODE_MMOUSEBTN = $1002

    ;* @addtogroup sounddevices
     ; @{ */

    ;*
     ; @brief The supported sound systems.
;    *
     ; @see SoundDevice
     ; @see TT_InitSoundInputDevice()
     ; @see TT_InitSoundOutputDevice()
     ; @see TT_InitSoundDuplexDevices() */
    Enumeration SoundSystem
            ;* @brief Sound system denoting invalid or not found. */
        #SOUNDSYSTEM_NONE = 0
        ;* @brief Windows legacy audio system. Should be used on Windows Mobile. */
        #SOUNDSYSTEM_WINMM = 1
        ;* @brief DirectSound audio system. Should be used on Windows 2K/XP. */
        #SOUNDSYSTEM_DSOUND = 2
        ;*
         ; @brief Advanced Linux Sound Architecture (ALSA). Should be used on Linux.
;   ;    *
         ; Often ALSA sound devices only support a limited number of
         ; sample rates so TeamTalk internally use software filters To
         ; resample the audio To the sample rate used by the selected
         ; audio codecs. */
        #SOUNDSYSTEM_ALSA = 3
        ;* @brief Core Audio. Should be used on MacOS. */
        #SOUNDSYSTEM_COREAUDIO = 4
        ;* @brief Windows Audio Session API (WASAPI). Should be used
         ; on Windows Vista/7.
;   ;    *
         ; WASAPI audio devices typically only support a single sample
         ; rate so internally TeamTalk uses software filters To
         ; resample audio To the sample rate used by the selected
         ; audio codecs.
         ; 
         ; Check @c supportedSampleRates And @c nDefaultSampleRate of
         ; #SoundDevice To see which sample rates are supported. */
        #SOUNDSYSTEM_WASAPI = 5
        #SOUNDSYSTEM_OPENSLES_ANDROID = 7
EndEnumeration

    ;* 
     ; @brief A struct containing the properties of a sound device
     ; For either playback Or recording.
;    *
     ; Use @a nDeviceID To pass To #TT_InitSoundInputDevice Or
     ; #TT_InitSoundOutputDevice.
;    *
     ; Note that the @a nDeviceID may change If the user application
     ; is restarted And a new sound device is added Or removed from
     ; the computer.
     ; 
     ; @see TT_GetSoundInputDevices
     ; @see TT_GetSoundOutputDevices */
    Structure SoundDevice
            ;* @brief The ID of the sound device. Used for passing to
         ; #TT_InitSoundInputDevice And
         ; #TT_InitSoundOutputDevice. Note that @a nDeviceID might change
         ; If USB sound devices are plugged in Or unplugged, therefore
         ; use @a szDeviceID To ensure proper device is used.  */
        nDeviceID.l
        ;* @brief The sound system used by the sound device */
        nSoundSystem.a ; values are members of SoundSystem
        ;* @brief The name of the sound device */
        szDeviceName.s{#TT_STRLEN}
        ;* @brief An identifier uniquely identifying the sound device
         ; even when new sound devices are being added And removed. In
         ; DirectSound, WASAPI And WinMM it would be the GUID of the sound
         ; device. Note that it may Not always be available. */
        szDeviceID.s{#TT_STRLEN}
CompilerIf #PB_Compiler_OS=#PB_OS_Windows
        ;* 
         ; @brief The ID of the device used in Win32's
         ; waveInGetDevCaps And waveOutGetDevCaps.
;   ;    *
         ; Value will be -1 If no ID could be found This ID can also
         ; be used To find the corresponding mixer on Windows passing
         ; it As @a nWaveDeviceID.  Note that this ID applies both To
         ; DirectSound And WinMM.
;   ;    *
         ; @see TT_Mixer_GetWaveInName
         ; @see TT_Mixer_GetWaveOutName
         ; @see TT_Mixer_GetMixerCount */
        nWaveDeviceID.l
CompilerEndIf
        ;* @brief Whether the sound device supports 3D-sound
         ; effects. */
        bSupports3D.a
        ;* @brief The maximum number of input channels. */
        nMaxInputChannels.l
        ;* @brief The maximum number of output channels. */
        nMaxOutputChannels.l
        ;* @brief Supported sample rates by device. A zero value terminates
         ; the List of supported sample rates Or its maximum size of 16. 
         ; Investigating the support sample rates is usually only required
         ; on Linux since sound devices often don't numerous sample rates. */
        supportedSampleRates.l[#TT_SAMPLERATES_MAX]
        ;* @brief The default sample rate for the sound device. */
        nDefaultSampleRate.l
    EndStructure
    
    ;*
     ; @brief An enum encapsulation the minimum, maximum And Default sound
     ; levels For input And output sound devices. */
    Enumeration  SoundLevel
            ;*
         ; @brief The maximum value of recorded audio.
         ; @see TT_GetSoundInputLevel
         ; @see TT_SetVoiceActivationLevel
         ; @see TT_GetVoiceActivationLevel */
        #SOUND_VU_MAX = 20
        ;*
         ; @brief The minimum value of recorded audio.
         ; @see TT_GetSoundInputLevel
         ; @see TT_SetVoiceActivationLevel
         ; @see TT_GetVoiceActivationLevel */
        #SOUND_VU_MIN = 0
        ;*
         ; @brief The maximum volume For master volume. To gain the
         ; volume level using software call #TT_SetUserGainLevel.
;   ;    *
         ; @see TT_SetSoundOutputVolume
         ; @see TT_GetSoundOutputVolume
         ; @see TT_SetUserVolume
         ; @see TT_GetUserVolume */
        #SOUND_VOLUME_MAX = 255
        ;*
         ; @brief The minimum volume For master volume.
         ; @see TT_SetSoundOutputVolume
         ; @see TT_GetSoundOutputVolume
         ; @see TT_SetUserVolume
         ; @see TT_GetUserVolume */
        #SOUND_VOLUME_MIN = 0
        ;*
         ; @brief The maximum gain level. 
;   ;    *
         ; A gain level of 32000 gains the volume by a factor 32.  A gain
         ; level of #SOUND_GAIN_DEFAULT means no gain.
;   ;    *
         ; @see TT_SetSoundInputGainLevel
         ; @see TT_GetSoundInputGainLevel
         ; @see TT_SetUserGainLevel
         ; @see TT_GetUserGainLevel */
        #SOUND_GAIN_MAX = 32000
        ;*
         ; @brief The Default gain level.
;   ;    *
         ; A gain level of 1000 means no gain. Check #SOUND_GAIN_MAX
         ; And #SOUND_GAIN_MIN To see how To increase And lower gain
         ; level.
;   ;    *
         ; @see TT_SetSoundInputGainLevel
         ; @see TT_GetSoundInputGainLevel
         ; @see TT_SetUserGainLevel
         ; @see TT_GetUserGainLevel */
        #SOUND_GAIN_DEFAULT = 1000
        ;*
         ; @brief The minimum gain level (since it's zero it means
         ; silence).
;   ;    *
         ; A gain level of 100 is 1/10 of the Default volume.
;   ;    *
         ; @see TT_SetSoundInputGainLevel
         ; @see TT_GetSoundInputGainLevel
         ; @see TT_SetUserGainLevel
         ; @see TT_GetUserGainLevel */
        #SOUND_GAIN_MIN = 0
    EndEnumeration

    ;*
     ; @brief Status of audio files being written To disk.
     ; @see WM_TEAMTALK_USER_AUDIOFILE */
    Enumeration AudioFileStatus
            ;* @brief Error while processing audio file. */
        #AFS_ERROR           = 0
        ;* @brief Started processing audio file. */
        #AFS_STARTED         = 1
        ;* @brief Finished processing audio file. */
        #AFS_FINISHED        = 2
        ;* @brief Aborted processing of audio file. */
        #AFS_ABORTED         = 3
    EndEnumeration

    ;*
     ; @brief Audio file formats supported For muxed audio recordings.
     ; @see TT_StartRecordingMuxedAudioFile() */
    Enumeration  AudioFileFormat
            ;* @brief Used to denote nothing selected. */
        #AFF_NONE                 = 0
        ;* @brief Store in 16-bit wave format. */
        #AFF_WAVE_FORMAT          = 2
        ;* @brief Store in MP3-format. 
;   ;    *
         ; This requires lame_enc.dll To be in the same directory As
         ; the application's execuable. The LAME DLLs can be obtained
         ; from http://lame.sourceforge.net. Note that the MP3-format
         ; is subject To licensing by Fraunhofer And Thomson
         ; Multimedia. */
        #AFF_MP3_64KBIT_FORMAT    = 3
        ;* @see #AFF_MP3_64KBIT_FORMAT */
        #AFF_MP3_128KBIT_FORMAT   = 4
        ;* @see #AFF_MP3_64KBIT_FORMAT */
        #AFF_MP3_256KBIT_FORMAT   = 5
        ;* @see #AFF_MP3_64KBIT_FORMAT */
        #AFF_MP3_16KBIT_FORMAT    = 6
        ;* @see #AFF_MP3_64KBIT_FORMAT */
        #AFF_MP3_32KBIT_FORMAT    = 7
    EndEnumeration

    ;*
     ; @brief An audio block containing the raw audio from a user who
     ; was talking.
;    *
     ; To enable audio blocks first call TT_EnableAudioBlockEvent()
     ; then whenever new audio is played the event
     ; #WM_TEAMTALK_USER_AUDIOBLOCK is generated. Use
     ; TT_AcquireUserAudioBlock() To retrieve the audio block.
;    *
     ; Note that each user is limited To 128 kbytes of audio Data.
;    *
     ; @see TT_EnableAudioBlockEvent()
     ; @see TT_AcquireUserAudioBlock()
     ; @see TT_ReleaseUserAudioBlock() */
    Structure AudioBlock
            ;* @brief The sample rate of the raw audio. */
        nSampleRate.l
        ;* @brief The number of channels used (1 for mono, 2 for stereo). */
        nChannels.l
        ;* @brief The raw audio in 16-bit integer format array. The
         ; size of the Array in bytes is @c SizeOf(short) ; @c
         ; nSamples ; @c nChannels. */
        *lpRawAudio
        ;* @brief The number of samples in the raw audio array. */
        nSamples.l
        ;* @brief The index of the first sample in @c lpRawAudio. Its
         ; value will be a multiple of @c nSamples. The sample index
         ; can be used To detect overflows of the internal
         ; buffer. When a user initially starts talking the @c
         ; nSampleIndex will be 0 And While the user is talking @c
         ; nSampleIndex will be greater than 0. When the user stops
         ; talking @c nSampleIndex will be reset To 0 again. */
        uSampleIndex.q
    EndStructure

    ;*
     ; @brief Struct describing the audio format used by a
     ; media file.
;    *
     ; @see TT_GetMediaFileInfo()
     ; @see MediaFileInfo
;    */
    Structure AudioFormat
            ;* @brief The audio file format, e.g. wave or MP3. */
        nAudioFmt.a ; values are members of AudioFileFormat 
        ;* @brief Sample rate of media file. */
        nSampleRate.l
        ;* @brief Channels used by media file, mono = 1, stereo = 2. */
        nChannels.l
    EndStructure

    ;* @} */

    ;* @addtogroup videocapture
     ; @{ */

    ;* 
     ; @brief The picture format used by a capture device. 
;    *
     ; @see CaptureFormat
     ; @see VideoCaptureDevice */
    Enumeration FourCC
            ;* @brief Internal use to denote no supported formats. */
        #FOURCC_NONE   =   0
        ;* @brief Prefered image format with the lowest bandwidth
         ; usage. A 640x480 pixel image takes up 460.800 bytes. */
        #FOURCC_I420   = 100
        ;* @brief Image format where a 640x480 pixel images takes up
         ; 614.400 bytes. */
        #FOURCC_YUY2   = 101
        ;* @brief The image format with the highest bandwidth
         ; usage. A 640x480 pixel images takes up 1.228.880 bytes. */
        #FOURCC_RGB32  = 102
    EndEnumeration

    ;* 
     ; @brief A struct containing the properties of a video capture
     ; format.
;    *
     ; A struct For holding a supported video capture format by a 
     ; #VideoCaptureDevice. */
    Structure CaptureFormat
            ;* @brief The width in pixels of the video device supported
         ; video format. */
        nWidth.l
        ;* @brief The height in pixels of the video device supported
         ; video format. */
        nHeight.l
        ;* @brief The numerator of the video capture device's video
         ; format. Divinding @a nFPS_Numerator With @a
         ; nFPS_Denominator gives the frame-rate. */
        nFPS_Numerator.l
        ;* @brief The denominator of the video capture device's video
         ; format. Divinding @a nFPS_Numerator With @a
         ; nFPS_Denominator gives the frame-rate.*/
        nFPS_Denominator.l
        ;* @brief Picture format for capturing. */
        picFourCC.l ; values are members of FourCC
    EndStructure

    ;*
     ; @brief A RGB32 image where the pixels can be accessed directly
     ; in an allocated @a frameBuffer.
;    *
     ; Use TT_AcquireUserVideoFrame() To acquire a user's image and
     ; remember To call TT_ReleaseUserVideoFrame() when the image has
     ; been processed so TeamTalk can release its resources. */
    Structure VideoFrame
            ;* @brief The width in pixels of the image contained in @a
         ; frameBuffer. */
        nWidth.l
        ;* @brief The height in pixels of the image contained in @a
         ; imageBuffer. */
        nHeight.l
        ;* @brief A unique identifier for the frames which are part of the
         ; same video sequence. If the stream ID changes it means the
         ; frames which are being received are part of a new video sequence
         ; And @a nWidth And @a nHeight may have changed. The @a nStreamID
         ; will always be a positive integer value.*/
        nStreamID.l
        ;* @brief Whether the image acquired is a key-frame. If it is
         ; Not a key-frame And there has been packet loss Or a
         ; key-frame has Not been acquired prior then the image may
         ; look blurred. */
        bKeyFrame.a
        ;* @brief A buffer allocated internally by TeamTalk. */
        *frameBuffer
        ;* @brief The size in bytes of the buffer allocate in @a
         ; frameBuffer. */
        nFrameBufferSize.l
    EndStructure

    ;* 
     ; @brief A struct containing the properties of a video capture
     ; device.
;    *
     ; The information retrieved from the video capture device is used
     ; To initialize the video capture device using the
     ; #TT_InitVideoCaptureDevice function.
     ; 
     ; @see TT_GetVideoCaptureDevices */
    Structure VideoCaptureDevice
            ;* @brief A string identifying the device. */
        szDeviceID.s{#TT_STRLEN}
        ;* @brief The name of the capture device. */
        szDeviceName.s{#TT_STRLEN}
        ;* @brief The name of the API used to capture video. */ 
        szCaptureAPI.s{#TT_STRLEN}
        ;* @brief The supported capture formats. */
        captureFormats.l[#TT_CAPTUREFORMATS_MAX] ; values are members of CaptureFormat
        ;* @brief The number of capture formats available in @a
         ; captureFormats Array. */
        nCaptureFormatsCount.l
    EndStructure

    ;*
     ; @brief Struct describing the audio And video format used by a
     ; media file.
;    *
     ; @see TT_GetMediaFile() */
    Structure MediaFileInfo
            ;* @brief The audio properties of the media file. */
        audioFmt.l ; values are members of AudioFormat 
        ;* @brief The video properties of the media file. */
        videoFmt.l ; values are members of CaptureFormat
        ;* @brief The duration of the media file in miliseconds. */
        uDurationMSec.l
    EndStructure

    ;* @} */

    ;* @addtogroup desktopshare
     ; @{ */

    ;*
     ; @brief The bitmap format used For a #DesktopWindow. */
    Enumeration BitmapFormat
            ;* @brief Used to denote nothing selected. */
        #BMP_NONE            = 0
        ;* @brief The bitmap is a 256-colored bitmap requiring a
         ; palette. The Default 256 colored palette is the Netscape
         ; browser-safe palette. Use TT_Palette_GetColorTable() To
         ; access Or change the palette. The maximum size of a 
         ; 8-bit bitmap is 4095 blocks of 120 by 34 pixels. */
        #BMP_RGB8_PALETTE    = 1
        ;* @brief The bitmap is a 16-bit colored bitmap. The maximum
         ; pixels. */
        #BMP_RGB16_555       = 2
        ;* @brief The bitmap is a 24-bit colored bitmap. The maximum
         ; size of a 24-bit bitmap is 4095 blocks of 85 by 16
         ; pixels. */
        #BMP_RGB24           = 3
        ;* @brief The bitmap is a 32-bit colored bitmap. The maximum
         ; size of a 32-bit bitmap is 4095 blocks of 51 by 20
         ; pixels. */
        #BMP_RGB32           = 4
    EndEnumeration

    ;* @brief The protocols supported for transferring a
     ; #DesktopWindow.
;    *
     ; So far only one, UDP-based, protocol is supported. */
    Enumeration DesktopProtocol
            ;* @brief Desktop protocol based on ZLIB for image
         ; compression And UDP For Data transmission. */
        #DESKTOPPROTOCOL_ZLIB_1  = 1
    EndEnumeration

    ;*
     ; @brief A struct containing the properties of a Shared desktop window.
;    *
     ; The desktop window is a description of the bitmap which can be retrieved using 
     ; TT_GetUserDesktopWindow() Or the bitmap which should be transmitted using
     ; TT_SendDesktopWindow(). */
    Structure DesktopWindow
            ;* @brief The width in pixels of the bitmap. */
        nWidth.l
        ;* @brief The height in pixels of the bitmap. */
        nHeight.l
        ;* @brief The format of the bitmap. */
        bmpFormat.l ; values are members of BitmapFormat
        ;* @brief The number of bytes for each scan-line in the
         ; bitmap. Zero means 4-byte aligned. */
        nBytesPerLine.l
        ;* @brief The ID of the session which the bitmap belongs
         ; To. If the session ID changes it means the user has started
         ; a new session. This e.g. happens If the desktop session has
         ; been closed And restart Or If the bitmap has been
         ; resized. Set @c nSessionID To 0 If the desktop window is
         ; used With TT_SendDesktopWindow(). */
        nSessionID.l
        ;* @brief The desktop protocol used for transmitting the desktop window. */
        nProtocol.l ; values are members of DesktopProtocol
    EndStructure

    ;*
     ; @brief The state of a key (Or mouse button), i.e. If it's
     ; pressed Or released. @see DesktopInput */
    Enumeration DesktopKeyState
            ;* @brief The key is ignored. */
        #DESKTOPKEYSTATE_NONE       = $00000000
        ;* @brief The key is pressed. */
        #DESKTOPKEYSTATE_DOWN       = $00000001
        ;* @brief The key is released. */
        #DESKTOPKEYSTATE_UP         = $00000002
    EndEnumeration

        ;*
     ; @brief A struct containing a mouse Or keyboard event.
;    *
     ; The DesktopInput struct is used For desktop access where a
     ; remote user can control mouse Or keybaord on a Shared
     ; desktop. Check out section @ref desktopinput on how To use
     ; remote desktop access. */
    Structure DesktopInput
            ;* @brief The X coordinate of the mouse. If used with
         ; TT_DesktopInput_Execute() And the mouse position should be
         ; ignored then set To #TT_DESKTOPINPUT_MOUSEPOS_IGNORE. */
        uMousePosX.l
        ;* @brief The Y coordinate of the mouse. If used with
         ; TT_DesktopInput_Execute() And the mouse position should be
         ; ignored then set To #TT_DESKTOPINPUT_MOUSEPOS_IGNORE. */
        uMousePosY.l
        ;* @brief The key-code (or mouse button) pressed. If used
         ; With TT_DesktopInput_Execute() And no key (Or mouse button)
         ; is pressed then set To #TT_DESKTOPINPUT_KEYCODE_IGNORE.
         ; Read section @ref transdesktopinput on issues With
         ; key-codes And keyboard settings. */
        uKeyCode.q
        ;* @brief The state of the key (or mouse button) pressed,
         ; i.e. If it's up or down. */
        uKeyState.l ; values are members of DesktopKeyState
    EndStructure

    ;* @} */

    ;* @addtogroup codecs
     ; @{ */

    ;* @brief Speex audio codec settings for Constant Bitrate mode
     ; (CBR). The Speex codec is recommended For voice And uses less
     ; bandwidth than #CELTCodec. @see SpeexVBRCodec */
    Structure SpeexCodec
            ;* @brief Set to 0 for 8 KHz (narrow band), set to 1 for 16 KHz 
         ; (wide band), set To 2 For 32 KHz (ultra-wide band). */
        nBandmode.l
        ;* @brief A value from 1-10. As of DLL version 4.2 also 0 is
         ; supported.*/
        nQuality.l
        ;* @brief Milliseconds of audio data in each packet. Speex
         ; uses 20 msec frame sizes. Recommended is 40 ms. Min is 20,
         ; max is 1000. */
        nMSecPerPacket.l
        ;* @brief Use Speex' jitter buffer for playback. Recommended
         ; is FALSE. */
        bUseJitterBuffer.a
        ;* @brief Playback should be done in stereo. Doing so will
         ; disable 3d-positioning.
;   ;    *
         ; @see TT_SetUserPosition
         ; @see TT_SetUserStereo */
        bStereoPlayback.a
    EndStructure

    ;* @brief Speex audio codec settings for Variable Bitrate mode
     ; (VBR). The Speex codec is recommended For voice And uses less
     ; bandwidth than #CELTCodec. The Speex VBR codec was introduced
     ; in version 4.2. */
    Structure SpeexVBRCodec
            ;* @brief Set to 0 for 8 KHz (narrow band), set to 1 for 16 KHz 
         ; (wide band), set To 2 For 32 KHz (ultra-wide band). */
        nBandmode.l
        ;* @brief A value from 0-10. If @c nBitRate is non-zero it
         ; will override this value. */
        nQualityVBR.l
        ;* @brief The bitrate at which the audio codec should output
         ; encoded audio Data. Dividing it by 8 gives roughly the
         ; number of bytes per second used For transmitting the
         ; encoded Data. For limits check out #SPEEX_NB_MIN_BITRATE,
         ; #SPEEX_NB_MAX_BITRATE, #SPEEX_WB_MIN_BITRATE,
         ; #SPEEX_WB_MAX_BITRATE, #SPEEX_UWB_MIN_BITRATE And
         ; #SPEEX_UWB_MAX_BITRATE. Note that specifying @c nBitRate
         ; will override nQualityVBR. */
        nBitRate.l
        ;* @brief The maximum bitrate at which the audio codec is
         ; allowed To output audio. Set To zero If it should be
         ; ignored. */
        nMaxBitRate.l
        ;* @brief Enable/disable discontinuous transmission. When
         ; enabled Speex will ignore silence, so the bitrate will
         ; become very low. */
        bDTX.a
        ;* @brief Milliseconds of audio data in each packet. Speex
         ; uses 20 msec frame sizes. Recommended is 40 ms. Min is 20,
         ; max is 1000. */
        nMSecPerPacket.l
        ;* @brief Use Speex' jitter buffer for playback. Recommended
         ; is FALSE. */
        bUseJitterBuffer.a
        ;* @brief Playback should be done in stereo. Doing so will
         ; disable 3d-positioning.
;   ;    *
         ; @see TT_SetUserPosition
         ; @see TT_SetUserStereo */
        bStereoPlayback.a 
    EndStructure

;* @brief The minimum bitrate for Speex codec in 8 KHz mode. Bandmode
; = 0. */
#SPEEX_NB_MIN_BITRATE = 2150
;* @brief The maximum bitrate for Speex codec in 8 KHz mode. Bandmode
; = 0. */
#SPEEX_NB_MAX_BITRATE = 24600
;* @brief The minimum bitrate for Speex codec in 16 KHz
; mode. Bandmode = 1. */
#SPEEX_WB_MIN_BITRATE = 3950
;* @brief The maximum bitrate for Speex codec in 16 KHz
; mode. Bandmode = 1. */
#SPEEX_WB_MAX_BITRATE = 42200
;* @brief The minimum bitrate for Speex codec in 32 KHz
; mode. Bandmode = 2. */
#SPEEX_UWB_MIN_BITRATE = 4150
;* @brief The maximum bitrate for Speex codec in 32 KHz
; mode. Bandmode = 2. */
#SPEEX_UWB_MAX_BITRATE = 44000

    ;* @brief CELT audio codec settings. The CELT codec is
     ; recommended For music And speech. It has a higher bandwidth
     ; usage than #SpeexCodec. */
    Structure  CELTCodec
            ;* @brief The sample rate to use. Sample rate must be in the
         ; range 32000 - 96000 Hz. */
        nSampleRate.l
        ;* @brief Mono = 1 or stereo = 2. Note that echo
         ; cancellation, denoising And AGC is Not support when using
         ; stereo.
;   ;    *
         ; @see TT_EnableEchoCancellation()
         ; @see TT_EnableDenoising()
         ; @see TT_EnableAGC() */
        nChannels.l
        ;* @brief The bitrate at which the audio codec should output
         ; encoded audio Data. Dividing it by 8 gives roughly the
         ; number of bytes per second used For transmitting the
         ; encoded Data. #CELT_MIN_BITRATE And #CELT_MAX_BITRATE
         ; specifies bitrate limited. */
        nBitRate.l
        ;* @brief Milliseconds of audio data in each
         ; packet. Recommended is 40 ms. Min is 20, max is 1000. */
        nMSecPerPacket.l
    EndStructure

    ;* @brief CELT audio codec settings. The CELT codec is
     ; recommended For music And speech. It has a higher bandwidth
     ; usage than #SpeexCodec. */
    Structure CELTVBRCodec
            ;* @brief The sample rate to use. Sample rate must be in the
         ; range 32000 - 96000 Hz. */
        nSampleRate.l
        ;* @brief Mono = 1 or stereo = 2. Note that echo
         ; cancellation, denoising And AGC is Not support when using
         ; stereo.
;   ;    *
         ; @see TT_EnableEchoCancellation()
         ; @see TT_EnableDenoising()
         ; @see TT_EnableAGC() */
        nChannels.l
        ;* @brief The bitrate at which the audio codec can output
         ; encoded audio Data. Dividing it by 8 gives roughly the
         ; number of bytes per second used For transmitting the
         ; encoded Data. @see CELT_MIN_BITRATE @see
         ; CELT_MAX_BITRATE */
        nBitRate.l
        ;* @brief Milliseconds of audio data in each
         ; packet. Recommended is 40 ms. Min is 20, max is 1000. */
        nMSecPerPacket.l
    EndStructure

;* @brief The minimum bitrate supported for CELT. */
#CELT_MIN_BITRATE = 35000
;* @brief The maximum bitrate supported for CELT. */
#CELT_MAX_BITRATE = 3000000

    ;* 
     ; @brief Theora video codec settings.
;    *
     ; Configuring the Theora codec so it fits an End-user's domain
     ; can be trickly. A high resolution in #CaptureFormat will result
     ; in much high bandwidth usage. Also using a high frame-rate will
     ; cause much higher bandwidth usage.
;    *
     ; Note that width And height For a video frame encoded by Theora
     ; must be a multiple of 16. If it is Not then part of the picture
     ; will be "cut" out. */
    Structure TheoraCodec
            ;* @brief The target bitrate in bits per second. If set to
         ; zero the Theora codec will use variable bitrate (VBR). If
         ; non-zero it will use constant bitrate (CBR). */
        nTargetBitRate.l
        ;* @brief A value from 0 - 63. Higher value gives higher
         ; quality. */
        nQuality.l
    EndStructure

    ;* @brief The codecs supported.
     ; @see AudioCodec
     ; @see VideoCodec */
    Enumeration Codec
            ;* @brief No codec specified. */
        #NO_CODEC                    = 0
        ;* @brief Speex audio codec, http://www.speex.org @see
         ; SpeexCodec */
        #SPEEX_CODEC                 = 1
        ;* @brief CELT audio codec version 0.5.2 used in version 4.1 and 
         ; prior, http://www.celt-codec.org.
;   ;    *
         ; This codec is Not supported in version 4.2 And later. */
        #CELT_0_5_2_OBSOLETE_CODEC   = 2
        ;* @brief Theora video codec, http://www.theora.org @see
         ; TheoraCodec */
        #THEORA_CODEC                = 3
        ;* @brief Speex audio codec in VBR mode, http://www.speex.org
         ; @see SpeexVBRCodec */
        #SPEEX_VBR_CODEC             = 4
        ;* @brief CELT audio codec version 0.11.1, 
         ; http://www.celt-codec.org @see CELTCodec */
        #CELT_CODEC                  = 5
        ;* @brief CELT audio codec version 0.11.1 in VBR mode, 
         ; http://www.celt-codec.org @see CELTVBRCodec */
        #CELT_VBR_CODEC              = 6
EndEnumeration

    ;* @brief Struct used for specifying which audio codec a channel
     ; uses. */
    Structure AudioCodec
            ;* @brief Specifies whether the member @a speex or @a celt holds
         ; the codec settings. */
        nCodec.l ; values are members of Codec
        StructureUnion
                    ;* @brief Speex codec settings if @a nCodec is
             ; #SPEEX_CODEC */
            speex.SpeexCodec
            ;* @brief CELT codec settings if @a nCodec is
             ; #CELT_CODEC */
            celt.CELTCodec
            ;* @brief Speex codec settings if @a nCodec is
             ; #SPEEX_VBR_CODEC */
            speex_vbr.SpeexVBRCodec
            ;* @brief CELT codec settings if @a nCodec is
             ; #CELT_VBR_CODEC */
            celt_vbr.CELTVBRCodec
EndStructureUnion
EndStructure

    ;* @brief Common audio configuration which should be used by users
     ; in the same #Channel.
;    *
     ; Users' audio levels may be diffent due to how their microphone
     ; is configured in their OS. Automatic Gain Control (AGC) can be used
     ; To ensure all users in the same channel have the same audio level.
;    *
     ; @see TT_DoMakeChannel()
     ; @see TT_DoUpdateChannel()
     ; @see TT_EnableAGC() */
    Structure AudioConfig
            ;* @brief Whether clients who join a #Channel should
         ; automatically enable AGC With the settings specified @a
         ; bGainLevel, @a @a nMaxIncDBSec, @a nMaxDecDBSec And @a
         ; nMaxGainDB. If the local client instance has already
         ; enabled the flag #CLIENT_SNDINPUT_AGC it will Not enable
         ; AGC automatically when joining the channel. */
        bEnableAGC.a
        ;* @brief A value from 0 to 32768. Default is 8000. */
        nGainLevel.l
        ;* @brief Used so volume should not be amplified too quickly 
         ; (maximal gain increase in dB/second). Default is 12. */
        nMaxIncDBSec.l
        ;* @brief Negative value! Used so volume should not be attenuated
         ; too quickly (maximal gain decrease in dB/second). Default is 
         ; -40. */
        nMaxDecDBSec.l
        ;* @brief Ensure volume doesn't become too loud (maximal gain
         ; in dB). Default is 30. */
        nMaxGainDB.l
        ;* @brief Whether clients who join the channel should automatically
         ; enable denoising. If the local client instance has already
         ; enabled the flag #CLIENT_SNDINPUT_DENOISING it will Not
         ; enable denoising automatically when joining a channel. */
        bEnableDenoise.a
        ;* @brief Negative value! Maximum attenuation of the noise in dB.
         ; Default value is -30. */
        nMaxNoiseSuppressDB.l
    EndStructure

    ;* @brief Struct used for specifying the video codec to use. */
    Structure VideoCodec
            ;* @brief Specifies member holds the codec settings. So far
         ; there is only one video codec To choose from, namely @a
         ; theora. */
        nCodec.l ; values are members of Codec
        StructureUnion
                    ;* @brief Theora codec settings if @a nCodec is
             ; #THEORA_CODEC. */
            theora.TheoraCodec
        EndStructureUnion
    EndStructure
    ;* @} */

    ;* @addtogroup transmission
     ; @{ */

    ;*
     ; @brief Enum specifying Data transmission types. @see
     ; TT_EnableTransmission @see TT_IsTransmitting */
    Enumeration TransmitType
            ;* @brief Transmitting nothing. */
        #TRANSMIT_NONE  = $0
         ;* @brief Transmit audio. */
        #TRANSMIT_AUDIO = $1
        ;* @brief Transmit video. */
        #TRANSMIT_VIDEO = $2
    EndEnumeration

    ;* @brief A mask of data transmissions based on
     ; #TransmitType. @see TT_EnableTransmission */
    ;typedef UINT32 TransmitTypes;    
    ;* @} */

    ;* @addtogroup server
     ; @{ */

    ;* 
     ; @brief The rights users have once they have logged on To the
     ; server.
;    *
     ; #ServerProperties holds the user rights in its \a uUserRights
     ; member variable And is retrieved by calling
     ; #TT_GetServerProperties once connected To the server.
;    *
     ; @see ServerProperties
     ; @see TT_GetServerProperties */
    Enumeration UserRight
            ;* @brief Users who log onto the server has none of the
          ; rights below. */
        #USERRIGHT_NONE                      = $00000000
        ;* @brief Users can log on without an account and by only
         ; specifying the server password. */
        #USERRIGHT_GUEST_LOGIN               = $00000001
        ;* @brief Users can see users in all other channels. This
         ; option cannot be changed in a call To #TT_DoUpdateServer. */
        #USERRIGHT_VIEW_ALL_USERS            = $00000002
        ;* @brief Users are allowed to create channels. */ 
        #USERRIGHT_CHANNEL_CREATION          = $00000004
        ;* @brief Users can become operators of channels. */
        #USERRIGHT_CHANNEL_OPERATORS         = $00000008
        ;* @brief Users can use channel commands (text messages
         ; prefixed With '/'. */
        #USERRIGHT_CHANNEL_COMMANDS          = $00000010
        ;* @brief None-admins are allowed to broadcast messages to
         ; all users. */
        #USERRIGHT_CLIENT_BROADCAST          = $00000020
         ;* @brief Users are allowed to change subscriptions to other
          ; users. */
        #USERRIGHT_SUBSCRIPTIONS             = $00000040
        ;* @brief Users are allowed to forward audio packets through
         ; server. */
        #USERRIGHT_FORWARD_AUDIO             = $00000080
        ;* @brief Users are allowed to forward video packets through
         ; server. */
        #USERRIGHT_FORWARD_VIDEO             = $00000100
        ;* @brief Allow multiple users to log on to the server with
         ; the same #UserAccount. */
        #USERRIGHT_DOUBLE_LOGIN              = $00000200
        ;* @brief Users are allowed to forward desktop packets through
         ; server. Requires server version 4.3.0.1490 Or later.*/
        #USERRIGHT_FORWARD_DESKTOP           = $00000400
        ;* @brief Users are only allowed to use valid UTF-8 strings.
         ; If a non-UTF-8 string is passed in a command the server will
         ; respond With the command error #CMDERR_SYNTAX_ERROR.
         ; @note Requires server version 4.3.1.1940 Or later. */
        #USERRIGHT_STRICT_UTF8               = $00000800
        ;* @brief Users are allowed to forward desktop input packets through
         ; server. Requires server version 4.6.0.2551 Or later.*/
        #USERRIGHT_FORWARD_DESKTOPINPUT      = $00001000
    EndEnumeration

    ;* 
     ; @brief A bitmask based on #UserRight For holding the rights users 
     ; have who log on the server.
     ; @see ServerProperties */
    ;typedef UINT32 UserRights;

    ;* 
     ; @brief A struct containing the properties of the server's
     ; settings.
;    *
     ; The server properties is available after a successful call To
     ; #TT_DoLogin
;    *
     ; @see TT_DoUpdateServer
     ; @see TT_GetServerProperties 
     ; @see TT_Login
     ; @see UserRight */
    Structure ServerProperties
            ;* @brief The server's name. */
        szServerName.s{#TT_STRLEN}
        ;* @brief The server's password to login. Users must provide
         ; this in the #TT_DoLogin command. When extracted through
         ; #TT_GetServerProperties the password will only be set For users of 
         ; user-type #USERTYPE_ADMIN. */
        szServerPasswd.s{#TT_STRLEN}
        ;* @brief The message of the day. When updating the MOTD an admin
         ; can use the variables %users% (number of users), %admins% (number
         ; of admins), %uptime% (hours, minutes And seconds the server has
         ; been online), %voicetx% (KBytes transmitted), %voicerx% (KBytes
         ; received) And %lastuser% (nickname of last user To log on To the
         ; server) As part of the MOTD. */
        szMOTD.s{#TT_STRLEN}
        ;* @brief The message of the day including variables. This property
         ; is only set For #USERTYPE_ADMIN users. Read-only property. */
        szMOTDRaw.s{#TT_STRLEN}
        ;* @brief A bitmask based on #UserRight which specifies the rights 
         ; a user have who logs onto the server. */
        uUserRights.l ; values are members of UserRight
        ;* @brief The maximum number of users allowed on the server.  A user
         ; With admin account can ignore this */
        nMaxUsers.l
        ;* @brief The maximum number of logins with wrong password before
         ; banning user's IP-address. */
        nMaxLoginAttempts.l
        ;* @brief The maximum number of users allowed to log in with the same
         ; IP-address. 0 means disabled. */
        nMaxLoginsPerIPAddress.l
        ;* @brief Bandwidth restriction for audio codecs created by 
         ; non-administrators. This value will hold the highest bitrate which 
         ; is allowed For audio codecs. 0 = no limit. @see AudioCodec */
        nAudioCodecBpsLimit.l
        ;* @brief The maximum number of bytes per second which the server 
         ; will allow For audio packets. If this value is exceeded the server
         ; will start dropping audio packets. 0 = disabled. */
        nMaxAudioTxPerSecond.l
        ;* @brief The maximum number of bytes per second which the server 
         ; will allow For video packets. If this value is exceeded the server
         ; will start dropping video packets. 0 = disabled. */
        nMaxVideoTxPerSecond.l
        ;* @brief The maximum number of bytes per second which the server 
         ; will allow For desktop packets. If this value is exceeded the server
         ; will start dropping desktop packets. 0 = disabled. */
        nMaxDesktopTxPerSecond.l
        ;* @brief The amount of bytes per second which the server 
         ; will allow For packet forwarding.  If this value is exceeded the server
         ; will start dropping packets. 0 = disabled. */
        nMaxTotalTxPerSecond.l
        ;* @brief Whether the server automatically saves changes */
        bAutoSave.a
        ;* @brief The server's TCP port. */
        nTcpPort.l
        ;* @brief The server's UDP port. */
        nUdpPort.l
        ;* @brief The number of seconds before a user who hasn't
         ; responded To keepalives will be kicked off the server. @see
         ; TT_SetKeepAliveInterval. */
        nUserTimeout.l
        ;* @brief The server version. Read-only property. */
        szServerVersion.s{#TT_STRLEN}
        ;* @brief The version of the server's protocol. Read-only 
         ; property. */
        szServerProtocolVersion.s{#TT_STRLEN}
    EndStructure

    ;*
     ; @brief A struct containing the server's statistics,
     ; i.e. bandwidth usage And user activity.
;    *
     ; Use TT_DoQueryServerStats() To query the server's statistics
     ; And when the command completes use TT_GetServerStatistics() To
     ; extract the statistics. */
    Structure ServerStatistics
            ;* @brief The number of bytes sent from the server to
         ; clients. */
        nTotalBytesTX.q
        ;* @brief The number of bytes received by the server from
         ; clients. */
        nTotalBytesRX.q
        ;* @brief The number of bytes in audio packets sent from the
         ;  server To clients. */
        nVoiceBytesTX.q
        ;* @brief The number of bytes in audio packets received by
         ;  the server from clients. */
        nVoiceBytesRX.q
        ;* @brief The number of bytes in video packets sent from the
         ;  server To clients. */
        nVideoBytesTX.q
        ;* @brief The number of bytes in video packets received by
         ;  the server from clients. */
        nVideoBytesRX.q
        ;* @brief The number of bytes in desktop packets sent from the
         ;  server To clients. */
        nDesktopBytesTX.q
        ;* @brief The number of bytes in desktop packets received by
         ;  the server from clients. */
        nDesktopBytesRX.q
        ;* @brief The server's uptime in msec. */
        nUptimeMSec.q
    EndStructure

    ;*
     ; @brief A struct containing the properties of a banned user.
     ; This struct is used by #TT_GetBannedUsers.
     ; @see TT_GetBannedUsers */
    Structure BannedUser
            ;* @brief IP-address of banned user. */
        szIpAddress.s{#TT_STRLEN}
        ;* @brief Channel where user was located when banned. */
        szChannelPath.s{#TT_STRLEN}
        ;* @brief Date and time when user was banned. */
        szBanTime.s{#TT_STRLEN}
        ;* @brief Nickname of banned user. */
        szNickname.s{#TT_STRLEN}
        ;* @brief Username of banned user. */
        szUsername.s{#TT_STRLEN}
    EndStructure

    ;* @ingroup users
     ; @brief The types of users supported. 
     ; @see User @see UserAccount */
    Enumeration UserType
           ;* @brief Used internally to denote an unauthenticated
         ; user. */
        #USERTYPE_NONE    = $0 
        ;* @brief A default user who can join channels. */
        #USERTYPE_DEFAULT = $01
        ;* @brief A user with administrator privileges. */
        #USERTYPE_ADMIN   = $02
    EndEnumeration

    ;* @ingroup users
     ; @brief A bitmask based on #UserType describing the user type.
     ; @see UserType */
    ;typedef UINT32 UserTypes;

    ;* 
     ; @brief A struct containing the properties of a user account.
;    *
     ; A registered user is one that has a user account on the server.
;    *
     ; @see TT_DoListUserAccounts
     ; @see TT_DoNewUserAccount
     ; @see TT_DoDeleteUserAccount */
    Structure UserAccount
        ;* @brief The account's username. */
        szUsername.s{#TT_STRLEN}
        ;* @brief The account's password. */
        szPassword.s{#TT_STRLEN}
        ;* @brief A bitmask of the type of user based on #UserType. */
        uUserType.l ; values are members of UserType
        ;* @brief A user data field which can be used for additional
         ; information. The @a nUserData field of the #User struct will
         ; contain this value when a user who logs in With this account. */
        nUserData.l
        ;* @brief Additional notes about this user. */
        szNote.s{#TT_STRLEN}
        ;* @brief User should (manually) join this channel after login.
         ; If an initial channel is specified in the user's account then
         ; no password is required For the user To join the channel.
         ; @see TT_DoJoinChannel() */
        szInitChannel.s{#TT_STRLEN}
        ;* @brief Channels where this user will automatically become channel
         ; operator when joining. @see TT_DoChannelOp() */
        autoOperatorChannels.l[#TT_CHANNELS_OPERATOR_MAX]
    EndStructure
    ;* @} */

    ;* @addtogroup users
     ; @{ */

    ;* 
     ; @brief A user by Default accepts audio, video And text messages
     ; from all users. Using subscribtions can, however, change what
     ; the local client instance is willing To accept from other
     ; users.
;    *
     ; By calling #TT_DoSubscribe And #TT_DoUnsubscribe the local
     ; client instance can tell the server (And thereby remote users)
     ; what he is willing To accept from other users.
;    *
     ; To check what a user subscribes To check out the #User struct's
     ; @a uLocalSubscriptions. The subscriptions With the prefix
     ; @c SUBSCRIBE_INTERCEPT_* options can be used To spy on users And
     ; receive Data from them even If one is Not participating in the
     ; same channel As they are.
;    *
     ; @see TT_DoSubscribe
     ; @see TT_DoUnsubscribe */
    Enumeration Subscription
        ;* @brief No subscriptions. */
        #SUBSCRIBE_NONE                    = $0000
        ;* @brief Subscribing to user text messages.
         ; @see #MSGTYPE_USER. */
        #SUBSCRIBE_USER_MSG                = $0001
        ;* @brief Subscribing to channel texxt messages.
         ; @see #MSGTYPE_CHANNEL. */
        #SUBSCRIBE_CHANNEL_MSG             = $0002
        ;* @brief Subscribing to broadcast text messsages. 
         ; @see #MSGTYPE_BROADCAST.*/
        #SUBSCRIBE_BROADCAST_MSG           = $0004
        ;* @brief Subscribing to audio. */
        #SUBSCRIBE_AUDIO                   = $0008
        ;* @brief Subscribing to video. */
        #SUBSCRIBE_VIDEO                   = $0010
        ;* @brief Subscribing to desktop sharing. */
        #SUBSCRIBE_DESKTOP                 = $0020
        ;* @brief Subscribing to custom user messages. 
         ; @see #MSGTYPE_CUSTOM. */
        #SUBSCRIBE_CUSTOM_MSG              = $0040
        ;* @brief Subscribing to desktop input.
         ; @see TT_GetUserDesktopInput()
         ; @see TT_SendDesktopInput() */
        #SUBSCRIBE_DESKTOPINPUT            = $0080
        ;* @brief Intercept all user text messages sent by a
        ; user. Only user-type #USERTYPE_ADMIN can do this. */
        #SUBSCRIBE_INTERCEPT_USER_MSG      = $0100
        ;* @brief Intercept all channel messages sent by a user. Only
        ; user-type #USERTYPE_ADMIN can do this. */
        #SUBSCRIBE_INTERCEPT_CHANNEL_MSG   = $0200
         ; #SUBSCRIBE_INTERCEPT_BROADCAST_MSG = $0400, */
        ;* @brief Intercept all audio sent by a user. Only user-type
         ; #USERTYPE_ADMIN can do this. By enabling this subscription an
         ; administrator can listen To audio sent by users outside his
         ; own channel. */
        #SUBSCRIBE_INTERCEPT_AUDIO         = $0800
        ;* @brief Intercept all video sent by a user. Only user-type
         ; #USERTYPE_ADMIN can do this. By enabling this subscription an
         ; administrator can receive video frames sent by users
         ; outside his own channel. */
        #SUBSCRIBE_INTERCEPT_VIDEO         = $1000
        ;* @brief Intercept all desktop data sent by a user. Only
         ; user-type #USERTYPE_ADMIN can do this. By enabling this
         ; subscription an administrator can views desktops
         ; sent by users outside his own channel. */
        #SUBSCRIBE_INTERCEPT_DESKTOP       = $2000
        ;* @brief Intercept all custom text messages sent by user. 
         ; Only user-type #USERTYPE_ADMIN can do this.  */
        #SUBSCRIBE_INTERCEPT_CUSTOM_MSG    = $4000
    EndEnumeration

    ;* 
     ; @brief A bitmask based on #Subscription describing which 
     ; subscriptions are enabled.
     ; @see Subscription */
    ;typedef UINT32 Subscriptions;

    ;* @brief The possible states for a user. Used for #User's @a
     ; uUserState variable. */
    Enumeration UserState
            ;* @brief The user is in initial state. */
        #USERSTATE_NONE          = $00
        ;* @brief If set the user is currently talking. Basically
         ; means the event #WM_TEAMTALK_USER_TALKING has been posted For
         ; this user. This flag doesn't apply to "myself". For
         ; "myself" (client instance) use #TT_IsTransmitting */
        #USERSTATE_TALKING       = $01
        ;* @brief If set the user is muted. @see TT_SetUserMute */
        #USERSTATE_MUTE          = $02
        ;* @brief Whether a peer to peer connection has been
         ; established To this user.  @see WM_TEAMTALK_CON_P2P */
        #USERSTATE_P2P_CONNECTED = $04
        ;* @brief If set the user currently has an active desktop session
         ; @see TT_SendDesktopWindow(). */
        #USERSTATE_DESKTOP       = $08
        ;* @brief If set the user currently has an active video stream
         ; @see TT_GetUserVideoFrame(). */
        #USERSTATE_VIDEO         = $10
    EndEnumeration

    ;* @brief A bitmask based on #UserState indicating a #User's current
     ; state. */
    ;typedef UINT32 UserStates;

    ;* 
     ; @brief A struct containing the properties of a user.
     ; @see UserType
     ; @see TT_GetUser */
    Structure User
           ;* @brief The user's ID. A value from 1 - 65535. */
        nUserID.l
         ;* @brief The user's nickname. @see TT_DoChangeNickname */
        szNickname.s{#TT_STRLEN}
        ;* @brief Username of user's account. */
        szUsername.s{#TT_STRLEN}
        ;* @brief The user's currently status mode. @see
         ; TT_DoChangeStatus() */
        nStatusMode.l
        ;* @brief The user's current status message. @see
         ; TT_DoChangeStatus() */
        szStatusMsg.s{#TT_STRLEN}
        ;* @brief The channel the user is currently participating
         ; in. 0 If none. */
        nChannelID.l 
        ;* @brief The user's IP-address. */ 
        szIPAddress.s{#TT_STRLEN}
        ;* @brief The user's client version. */ 
        szVersion.s{#TT_STRLEN}
        ;* @brief A bitmask of the type of user based on #UserType. */
        uUserType.l ; values are members of UserType
        ;* @brief A bitmask of the user's current state, e.g. talking, muted,
         ; etc. */
        uUserState.l ; values are members of UserState
        ;* @brief A bitmask of what the local user subscribes to from
         ; this user.  @see TT_DoSubscribe */
        uLocalSubscriptions.l ; values are members of Subscription
        ;* @brief A bitmask of what this user subscribes to from local
         ; user.  @see TT_DoSubscribe */
        uPeerSubscriptions.l ; members are values of Subscription
        ;* @brief The @a nUserData of the #UserAccount used by the user to
         ; log in. This field can be use To denote e.g. a database ID. */
        nUserData.l
        ;* @brief Store audio received from this user to this
         ; folder. @see TT_SetUserAudioFolder */
        szAudioFolder.s{#TT_STRLEN}
        ;* @brief The #AudioFileFormat used for audio files. 
         ; @see TT_SetUserAudioFolder() */
        uAFF.l ; members are values of AudioFileFormat
        ;* @brief Name of audio file currently being recorded. @see
         ; TT_SetUserAudioFolder() */
        szAudioFileName.s{#TT_STRLEN}
    EndStructure

    ;*
     ; @brief Packet reception And Data statistics For a user.
     ; 
     ; @see TT_GetUserStatistics */
    Structure UserStatistics
            ;* @brief Number of audio packets received from user. */
        nAudioPacketsRecv.q
        ;* @brief Number of audio packets lost from user. */
        nAudioPacketsLost.q
        ;* @brief Number of video packets received from user. A video 
         ; frame can consist of several video packets. */
        nVideoPacketsRecv.q
        ;* @brief Number of video frames received from user. */
        nVideoFramesRecv.q
        ;* @brief Video frames which couldn't be shown because packets were
         ; lost. */
        nVideoFramesLost.q
        ;* @brief Number of video frames dropped because user application  
         ; didn't retrieve video frames in time. */
        nVideoFramesDropped.q
    EndStructure

    ;* 
     ; @brief Text message types.
     ; 
     ; The types of messages which can be passed To #TT_DoTextMessage().
;    *
     ; @see TextMessage
     ; @see TT_DoTextMessage
     ; @see TT_GetTextMessage */ 
    Enumeration TextMsgType
            ;* @brief A User to user text message. A message of this
          ; type can be sent across channels. */
        #MSGTYPE_USER      = 1
        ;* @brief A User to channel text message. Users of type
         ; #USERTYPE_DEFAULT can only send this text message To the
         ; channel they're participating in, whereas users of type
         ; #USERTYPE_ADMIN can send To any channel. */
        #MSGTYPE_CHANNEL   = 2
         ;* @brief A broadcast message. Only admins can send
          ; broadcast messages unless #USERRIGHT_CLIENT_BROADCAST is
          ; enabled. */
        #MSGTYPE_BROADCAST = 3
        ;* @brief A custom user to user text message. Works the same
         ; way As #MSGTYPE_USER. */
        #MSGTYPE_CUSTOM    = 4
    EndEnumeration

    ;* 
     ; @brief A struct containing the properties of a text message
     ; sent by a user.
;    *
     ; @see WM_TEAMTALK_CMD_USER_TEXTMSG
     ; @see TT_DoTextMessage
     ; @see TT_GetTextMessage */
    Structure TextMessage
            ;* @brief The type of text message. */
        nMsgType.l ; members are values of TextMsgType
        ;* @brief Will be set automatically on outgoing message. */
        nFromUserID.l
        ;* @brief The originators username. */
        szFromUsername.s{#TT_STRLEN}
        ;* @brief Set to zero if channel message. */
        nToUserID.l
        ;* @brief Set to zero if @a nMsgType is #MSGTYPE_USER or
         ; #MSGTYPE_BROADCAST. */
        nChannelID.l
        ;* @brief The actual text message. The message can be
         ; multi-Line (include EOL).  */
        szMessage.s{#TT_STRLEN}
    EndStructure
    ;* @} */

    ;* @addtogroup channels
     ; @{ */

    ;*
     ; @brief The types of channels supported. @see Channel */
    Enumeration ChannelType
            ;* @brief A default channel is a channel which disappears
         ; after the last user leaves the channel. */
        #CHANNEL_DEFAULT             = $0000
        ;* @brief A channel which persists even when the last user
         ; leaves the channel. */
        #CHANNEL_STATIC              = $0001
        ;* @brief Only one user can transmit at a time. Note that
         ; this option doesn't apply if clients are running in peer to
         ; peer mode. @see #TT_EnablePeerToPeer */
        #CHANNEL_SOLO_TRANSMIT       = $0002
        ;* @brief Audio transmitted to the channel by the client
         ; instance is also sent back And played by the client
         ; instance. */
        #CHANNEL_ECHO                = $0004
        ;* @brief Same as #CHANNEL_ECHO. */
        #CHANNEL_ECHO_AUDIO          = $0004
        ;* @brief Voice and video transmission in the channel is controlled 
         ; by a channel operator (Or an administrator). For a user To
         ; transmit audio Or video To this type of channel the channel operator must
         ; add the user's ID to either @a voiceUsers or @a videoUsers in the
         ; #Channel struct And call #TT_DoUpdateChannel.
;   ;    *
         ; @note
         ; Requires server version 4.1.0.994 Or later.
;   ;    *
         ; @see TT_IsChannelOperator
         ; @see #USERTYPE_ADMIN */
        #CHANNEL_CLASSROOM           = $0008
        ;* @brief Video sent to the channel should also be sent back
         ; To the local client instance. */
        #CHANNEL_ECHO_VIDEO          = $0010
        ;* @brief Desktop session sent to the channel should also be
         ; sent back To the local client instance. */
        #CHANNEL_ECHO_DESKTOP        = $0020
        ;* @brief Only channel operators (and administrators) will receive 
         ; audio/video/desktop transmissions. Default channel users 
         ; will only see transmissions from operators And/Or 
         ; administrators. */
        #CHANNEL_OPERATOR_RECVONLY   = $0040
    EndEnumeration

    ;* 
     ; @brief Bitmask of #ChannelType. */
    ;typedef UINT32 ChannelTypes;

    ;* 
     ; @brief A struct containing the properties of a channel.
     ; @see TT_GetChannel
     ; @see ChannelType
     ; @see AudioCodec */
    Structure Channel
            ;* @brief Parent channel ID. 0 means no parent channel,
         ; i.e. it's the root channel. */
        nParentID.l
        ;* @brief The channel's ID. A value from 1 - 65535. */
        nChannelID.l
        ;* @brief Name of the channel. */
        szName.s{#TT_STRLEN}
        ;* @brief Topic of the channel. */
        szTopic.s{#TT_STRLEN}
        ;* @brief Password to join the channel. When extracted through
         ; #TT_GetChannel the password will only be set For users of 
         ; user-type #USERTYPE_ADMIN. */
        szPassword.s{#TT_STRLEN}
        ;* @brief Whether password is required to join channel */
        bPassword.a
        ;* @brief A bitmask of the type of channel based on #ChannelType. */
        uChannelType.l ; values are members of ChannelType
        ;* @brief Number of bytes available for file storage. */
        nDiskQuota.q
        ;* @brief Operator password, i.e. for use with '/opme'
         ; command. @see USERRIGHT_CHANNEL_COMMANDS */
        szOpPassword.s{#TT_STRLEN}
        ;* @brief Max number of users in channel. */
        nMaxUsers.l
        ;* @brief The audio codec used by users in the channel. */
        codec.AudioCodec
        ;* @brief The audio configuration which users who join the channel
         ; should use. If the audio configuration forces some options, e.g. 
         ; AGC And denoising then these options will automatically be enabled
         ; And override what is currently set by TT_EnableDenoising() And 
         ; TT_EnableAGC().
;   ;    *
         ; @note
         ; Requires server And client version 4.1.0.1127 Or later. */
        audiocfg.AudioConfig
        ;* @brief The IDs of users who are allowed to transmit voice 
         ; Data To the channel. This setting only applies To channels of type 
         ; #CHANNEL_CLASSROOM. Only channel operators And administrators are
         ; allowed To change the users who are allowed To transmit Data To a 
         ; channel. Call #TT_DoUpdateChannel To update the List of users who
         ; are allowed To transmit Data To the channel.
;   ;    *
         ; @note
         ; Requires server version 4.1.0.994 Or later.
;   ;    *
         ; @see TT_IsChannelOperator
         ; @see TT_DoChannelOp
         ; @see TRANSMIT_AUDIO
         ; @see TT_CLASSROOM_FREEFORALL */
        voiceUsers.l[#TT_VOICEUSERS_MAX]
        ;* @brief The IDs of users who are allowed to transmit video 
         ; Data To the channel. This setting only applies To channels of type 
         ; #CHANNEL_CLASSROOM. Only channel operators And administrators are
         ; allowed To change the users who are allowed To transmit Data To a 
         ; channel. Call #TT_DoUpdateChannel To update the List of users who
         ; are allowed To transmit Data To the channel.
;   ;    *
         ; @note
         ; Requires server version 4.1.0.994 Or later.
;   ;    *
         ; @see TT_IsChannelOperator
         ; @see TT_DoChannelOp
         ; @see TRANSMIT_VIDEO
         ; @see TT_CLASSROOM_FREEFORALL */
        videoUsers.l[#TT_VIDEOUSERS_MAX]
        ;* @brief The IDs of users who are allowed to share their
         ; desktop To the channel. This setting only applies To
         ; channels of type #CHANNEL_CLASSROOM. Only channel operators
         ; And administrators are allowed To change the users who are
         ; allowed To transmit Data To a channel. Call
         ; TT_DoUpdateChannel() To update the List of users who are
         ; allowed To transmit Data To the channel.
;   ;    *
         ; @note
         ; Requires server version 4.3.0.1490 Or later.
;   ;    *
         ; @see TT_IsChannelOperator()
         ; @see TT_DoChannelOp()
         ; @see TT_SendDesktopWindow()
         ; @see TT_CLASSROOM_FREEFORALL */
        desktopUsers.l[#TT_DESKTOPUSERS_MAX]
    EndStructure

    ;* 
     ; @brief A struct containing the properties of a file transfer.
     ; @see TT_GetFileTransferInfo */
    Structure FileTransfer
           ;* @brief The ID identifying the file transfer. */
        nTransferID.l
        ;* @brief The channel where the file is/will be located. */
        nChannelID.l
        ;* @brief The file path on local disk. */
        szLocalFilePath.s{#TT_STRLEN}
        ;* @brief The filename in the channel. */
        szRemoteFileName.s{#TT_STRLEN}
        ;* @brief The size of the file being transferred. */
        nFileSize.q
        ;* @brief The number of bytes transferred so far. */
        nTransferred.q
        ;* @brief TRUE if download and FALSE if upload. */
        bInbound.a
    EndStructure

    ;* @brief Status of a file transfer.
     ; @see WM_TEAMTALK_FILETRANSFER */
    Enumeration FileTransferStatus
            ;* @brief Error during file transfer. */
        #FILETRANSFER_ERROR      = 0
        ;* @brief File transfer started. */
        #FILETRANSFER_STARTED    = 1
        ;* @brief File transfer finished. */
        #FILETRANSFER_FINISHED   = 2
    EndEnumeration

    ;*
     ; @brief A struct containing the properties of a file in a #Channel.
     ; @see TT_GetChannelFileInfo */
    Structure FileInfo
            ;* @brief The ID identifying the file. */
        nFileID.l
        ;* @brief The name of the file. */
        szFileName.s{#TT_STRLEN}
        ;* @brief The size of the file. */
        nFileSize.q
        ;* @brief Username of the person who uploaded the files. */
        szUsername.s{#TT_STRLEN}
    EndStructure
    ;* @} */

    ;* @ingroup connectivity
     ; @brief Statistics of bandwidth usage And ping times in the local 
     ; client instance.
     ; @see TT_GetStatistics */
    Structure ClientStatistics
            ;* @brief Bytes sent on UDP. */
        nUdpBytesSent.q
        ;* @brief Bytes received on UDP. */
        nUdpBytesRecv.q
        ;* @brief Voice data sent (on UDP). */
        nVoiceBytesSent.q
        ;* @brief Voice data received (on UDP). */
        nVoiceBytesRecv.q
        ;* @brief Video data sent (on UDP). */
        nVideoBytesSent.q
        ;* @brief Video data received (on UDP). */
        nVideoBytesRecv.q
        ;* @brief Desktop data sent (on UDP). */
        nDesktopBytesSent.q
        ;* @brief Desktop data received (on UDP). */
        nDesktopBytesRecv.q
        ;* @brief Response time to server on UDP (based on ping/pong
         ; sent at a specified interval. Set To -1 If Not currently
         ; available. @see TT_SetKeepAliveInterval */
        nUdpPingTimeMs.l
        ;* @brief Response time to server on TCP (based on ping/pong
         ; sent at a specified interval. Set To -1 If Not currently
         ; available.  @see TT_SetKeepAliveInterval */
        nTcpPingTimeMs.l
        ;* @brief The number of seconds nothing has been received by
         ; the client on TCP. */
        nTcpServerSilenceSec.l
        ;* @brief The number of seconds nothing has been received by
         ; the client on UDP. */
        nUdpServerSilenceSec.l
    EndStructure

    ;* @addtogroup errorhandling
     ; @{ */

    ;* 
     ; @brief Errors which can occur either As a result of client
     ; commands Or As a result of internal errors.
;    *
     ; Use #TT_GetErrorMessage To get a text-description of the
     ; error. */
    Enumeration ClientError
            ;* @brief Command indicating success. Only used internally. */
        #CMDERR_SUCCESS = 0

        ; COMMAND ERRORS 1000-1999 ARE DUE TO INVALID OR UNSUPPORTED
         ; COMMANDS */

        ;* @brief Command has syntax error. Only used internally. */
        #CMDERR_SYNTAX_ERROR = 1000
        ;* @brief The server doesn't support the issued command.
;   ;    *
         ; This error may occur If the server is an older version than
         ; the client instance. */
        #CMDERR_UNKNOWN_COMMAND = 1001
        ;* @brief Command cannot be performed due to missing
         ; parameter. Only used internally. */
        #CMDERR_MISSING_PARAMETER = 1002
        ;* @brief The server uses a protocol which is incompatible
         ; With the client instance. */
        #CMDERR_INCOMPATIBLE_PROTOCOLS = 1003
        ;* @brief The server does not support the audio codec specified
         ; by the client. Introduced in version 4.1.0.1264. 
         ; @see TT_DoMakeChannel
         ; @see TT_DoJoinChannel */
        #CMDERR_UNKNOWN_AUDIOCODEC = 1004

        ; COMMAND ERRORS 2000-2999 ARE DUE TO INSUFFICIENT RIGHTS */

        ;* @brief Invalid server password. 
;   ;    *
         ; The #TT_DoLogin command passed a server password which was
         ; invalid.  @see TT_DoLogin */
        #CMDERR_INCORRECT_SERVER_PASSWORD = 2000
        ;* @brief Invalid channel password. 
;   ;    *
         ; The #TT_DoJoinChannel Or #TT_DoJoinChannelByID passed an
         ; invalid channel password. #TT_DoMakeChannel can also cause
         ; a this error If the password is longer than #TT_STRLEN. */
        #CMDERR_INCORRECT_CHANNEL_PASSWORD = 2001
        ;* @brief Invalid username or password for account.
;   ;    *
         ; The #TT_DoLogin command was issued With invalid account
         ; properties. This error can also occur by
         ; #TT_DoNewUserAccount If username is empty. */
        #CMDERR_INVALID_ACCOUNT = 2002
        ;* @brief Login failed due to maximum number of users on
         ; server.
;   ;    *
         ; #TT_DoLogin failed because the server does Not allow any
         ; more users. */
        #CMDERR_MAX_SERVER_USERS_EXCEEDED = 2003
        ;* @brief Cannot join channel because it has maximum number
         ; of users.
;   ;    *
         ; #TT_DoJoinChannel Or #TT_DoJoinChannelByID failed because
         ; no more users are allowed in the channel. */
        #CMDERR_MAX_CHANNEL_USERS_EXCEEDED = 2004
        ;* @brief IP-address has been banned from server.
;   ;    *
         ; #TT_DoLogin failed because the local client's IP-address
         ; has been banned on the server. */
        #CMDERR_SERVER_BANNED = 2005
        ;* @brief Command not authorized.
;   ;    *
         ; The command cannot be performed because the client instance
         ; has insufficient rights.
;   ;    *
         ; @see TT_DoDeleteFile
         ; @see TT_DoJoinChannel
         ; @see TT_DoJoinChannelByID
         ; @see TT_DoLeaveChannel
         ; @see TT_DoChannelOp
         ; @see TT_DoChannelOpEx
         ; @see TT_DoKickUser
         ; @see TT_DoUpdateChannel
         ; @see TT_DoChangeNickname
         ; @see TT_DoChangeStatus
         ; @see TT_DoTextMessage
         ; @see TT_DoSubscribe
         ; @see TT_DoUnsubscribe
         ; @see TT_DoMakeChannel
         ; @see TT_DoRemoveChannel
         ; @see TT_DoMoveUser
         ; @see TT_DoUpdateServer
         ; @see TT_DoSaveConfig
         ; @see TT_DoSendFile 
         ; @see TT_DoRecvFile 
         ; @see TT_DoBanUser
         ; @see TT_DoUnBanUser
         ; @see TT_DoListBans
         ; @see TT_DoListUserAccounts
         ; @see TT_DoNewUserAccount
         ; @see TT_DoDeleteUserAccount */
        #CMDERR_NOT_AUTHORIZED = 2006
         ;* @brief Server doesn't allow users to create channels.
 ;   ;    *
          ; #TT_DoJoinChannel Or #TT_DoJoinChannelByID failed because
          ; #USERRIGHT_CHANNEL_CREATION is Not enabled.  
          ; @see ServerProperties */
        #CMDERR_CANNOT_CREATE_CHANNELS = 2007
        ;* @brief Cannot upload file because disk quota will be exceeded.
;   ;    *
         ; #TT_DoSendFile was Not allowed because there's not enough
         ; disk space available For upload.
;   ;    *
         ; @see Channel */
        #CMDERR_MAX_DISKUSAGE_EXCEEDED = 2008
        ;* @brief Modifying subscriptions not enabled.
;   ;    *
         ; #TT_DoSubscribe Or #TT_DoUnsubscribe failed because the
         ; server does Not allow users To change subscriptions. The
         ; USERRIGHT_SUBSCRIPTIONS is Not enabled in the server's
         ; #ServerProperties.
;   ;    *
         ; @see ServerProperties */
        #CMDERR_SUBSCRIPTIONS_DISABLED = 2009
        ;* @brief Invalid password for becoming channel operator.
         ; 
         ; The password specified in #TT_DoChannelOpEx is Not correct.
         ; The operator password is the @a szOpPassword of the 
         ; #Channel-struct. */
        #CMDERR_INCORRECT_OP_PASSWORD = 2010

        ;* @brief The selected #AudioCodec exceeds what the server allows.
;   ;    *
         ; A server can limit the vitrate of audio codecs If @c 
         ; nAudioCodecBpsLimit of #ServerProperties is specified. */
        #CMDERR_AUDIOCODEC_BITRATE_LIMIT_EXCEEDED = 2011

        ;* @brief The maximum number of logins allowed per IP-address has
         ; been exceeded.
         ; 
         ; @see ServerProperties
         ; @see TT_DoLogin() */
        #CMDERR_MAX_LOGINS_PER_IPADDRESS_EXCEEDED = 2012

        ; COMMAND ERRORS 3000-3999 ARE DUE TO INVALID STATE OF CLIENT INSTANCE */

        ;* @brief Client instance has not been authenticated.
         ; 
         ; #TT_DoLogin has Not been issued successfully Or
         ; #TT_DoLogout could Not be performed because client
         ; instance is already logged in.*/
        #CMDERR_NOT_LOGGEDIN = 3000

        ;* @brief Already logged in.
;   ;    *
         ; #TT_DoLogin cannot be performed twice. */
        #CMDERR_ALREADY_LOGGEDIN = 3001
        ;* @brief Cannot leave channel because not in channel.
;   ;    *
         ; #TT_DoLeaveChannel failed because user is Not in a channel. */
        #CMDERR_NOT_IN_CHANNEL = 3002
        ;* @brief Cannot join same channel twice.
         ; 
         ; #TT_DoJoinChannel Or #TT_DoJoinChannelByID failed because
         ; client instance is already in the specified channel. */
        #CMDERR_ALREADY_IN_CHANNEL = 3003
        ;* @brief Channel already exists.
;   ;    *
         ; #TT_DoMakeChannel failed because channel already exists. */
        #CMDERR_CHANNEL_ALREADY_EXISTS = 3004
        ;* @brief Channel does not exist.
;   ;    *
         ; Command failed because channel does Not exists.
         ; @see TT_DoRemoveChannel
         ; @see TT_DoUpdateChannel
         ; @see TT_DoMakeChannel Due To invalid channel name
         ; @see TT_DoSendFile
         ; @see TT_DoRecvFile
         ; @see TT_DoDeleteFile
         ; @see TT_DoJoinChannel
         ; @see TT_DoJoinChannelByID
         ; @see TT_DoLeaveChannel
         ; @see TT_DoChannelOp
         ; @see TT_DoKickUser
         ; @see TT_DoBanUser
         ; @see TT_DoMoveUser
         ; @see TT_DoTextMessage */
        #CMDERR_CHANNEL_NOT_FOUND = 3005
        ;* @brief User not found.
         ; 
         ; Command failed because user does Not exists.
         ; @see TT_DoChannelOp
         ; @see TT_DoKickUser
         ; @see TT_DoBanUser
         ; @see TT_DoMoveUser
         ; @see TT_DoTextMessage
         ; @see TT_DoSubscribe
         ; @see TT_DoUnsubscribe */
        #CMDERR_USER_NOT_FOUND = 3006
        ;* @brief Banned IP-address does not exist.
         ; 
         ; #TT_DoUnBanUser failed because there is no banned
         ; IP-address which matches what was specified. */
        #CMDERR_BAN_NOT_FOUND = 3007
        ;* @brief File transfer doesn't exists.
;   ;    *
         ; #TT_DoSendFile Or #TT_DoRecvFile failed because the server
         ; cannot process the file transfer. */
        #CMDERR_FILETRANSFER_NOT_FOUND = 3008
        ;* @brief Server failed to open file.
;   ;    *
         ; #TT_DoSendFile Or #TT_DoRecvFile failed because the server
         ; cannot open the specified file (possible file lock). */
        #CMDERR_OPENFILE_FAILED = 3009
        ;* @brief Cannot find user account.
         ; 
         ; #TT_DoDeleteUserAccount failed because the specified user
         ; account does Not exists. */
        #CMDERR_ACCOUNT_NOT_FOUND = 3010
        ;* @brief File does not exist.
;   ;    *
         ; #TT_DoSendFile, #TT_DoRecvFile Or #TT_DoDeleteFile failed
         ; because the server cannot find the specified file. */
        #CMDERR_FILE_NOT_FOUND = 3011
        ;* @brief File already exist.
;   ;    *
         ; #TT_DoSendFile failed because the file already exists in
         ; the channel. */
        #CMDERR_FILE_ALREADY_EXISTS = 3012
        ;* @brief Server does not allow file transfers.
;   ;    *
         ; #TT_DoSendFile Or #TT_DoRecvFile failed because the server
         ; does Not allow file transfers. */
        #CMDERR_FILESHARING_DISABLED = 3013
        ;* @brief Cannot process command since server is not empty.
         ; @see TT_DoUpdateServer Ensure Not To update 
         ; #USERRIGHT_VIEW_ALL_USERS. */
        #CMDERR_SERVER_HAS_USERS = 3014
        ;* @brief Cannot process command since channel is not empty.
         ; @see TT_DoUpdateChannel #AudioCodec cannot be changed While
         ; there are users in a channel. */
        #CMDERR_CHANNEL_HAS_USERS = 3015

        ; ERRORS 10000-10999 ARE NOT COMMAND ERRORS BUT INSTEAD
         ; ERRORS IN THE CLIENT INSTANCE. */

        ;* @brief A sound input device failed. 
;   ;    *
         ; This can e.g. happen when joining a channel And the sound
         ; input device has been unplugged. 
         ; 
         ; Call #TT_CloseSoundInputDevice And TT_InitSoundInputDevice
         ; With a valid #SoundDevice To releave the problem. */
        #INTERR_SNDINPUT_FAILURE = 10000
        ;* @brief A sound output device failed.
;   ;    *
         ; This can e.g. happen when joining a channel And the sound
         ; output device has been unplugged. Note that it can be posted
         ; multiple times If there's several users in the channel.
;   ;    *
         ; Call #TT_CloseSoundOutputDevice And TT_InitSoundOutputDevice
         ; With a valid #SoundDevice To releave the problem. */
        #INTERR_SNDOUTPUT_FAILURE = 10001
    EndEnumeration
    ;* @} */

    ;* @addtogroup initclient
     ; @{ */

    ;*
     ; @brief Flags used To describe the the client instance current
     ; state.
;    *
     ; The client's state is a bitmask of the flags in #ClientFlag.
;    *
     ; The state of the client instance can be retrieved by calling
     ; #TT_GetFlags. This enables the user application To display the
     ; possible options To the End user. If e.g. the flag
     ; #CLIENT_AUTHORIZED is Not set it will Not be possible To
     ; perform any other commands except #TT_DoLogin. Doing so will
     ; make the server Return an error message To the client. */
    Enumeration ClientFlag
            ;* @brief The client instance (#TTInstance) is in closed
         ; state, i.e. #TT_InitTeamTalk has Return a valid instance
         ; ready For use but no operations has been performed on
         ; it. */
        #CLIENT_CLOSED                    = $00000000
        ;* @brief If set the client instance's sound input device has
         ; been initialized, i.e. #TT_InitSoundInputDevice has been
         ; called successfully. */
        #CLIENT_SNDINPUT_READY            = $00000001
        ;* @brief If set the client instance's sound output device
         ; has been initialized, i.e. #TT_InitSoundOutputDevice has
         ; been called successfully. */
        #CLIENT_SNDOUTPUT_READY           = $00000002
        ;* @brief If set the client instance's video device has been
         ; initialized, i.e. #TT_InitVideoCaptureDevice has been
         ; called successfuly. */
        #CLIENT_VIDEO_READY               = $00000004
        ;* @brief If set the client instance current have an active
         ; desktop session, i.e. TT_SendDesktopWindow() has been
         ; called. Call TT_CloseDesktopWindow() To close the desktop
         ; session. */
        #CLIENT_DESKTOP_ACTIVE            = $00000008
        ;* @brief If set the client instance will start transmitting
         ; audio If the sound level is above the voice activation
         ; level. The event #WM_TEAMTALK_VOICE_ACTIVATION is posted
         ; when voice activation initiates transmission.
         ; @see TT_SetVoiceActivationLevel
         ; @see TT_EnableVoiceActivation */
        #CLIENT_SNDINPUT_VOICEACTIVATED   = $00000010
        ;* @brief If set the client instance will try to remove noise
         ; from recorded audio. @see TT_EnableDenoising */
        #CLIENT_SNDINPUT_DENOISING        = $00000020
        ;* @brief If set the client instance is using automatic gain 
         ; control. @see TT_EnableAGC */
        #CLIENT_SNDINPUT_AGC              = $00000040
        ;* @brief If set the client instance has muted all users.
        ; @see TT_SetSoundOutputMute */
        #CLIENT_SNDOUTPUT_MUTE            = $00000080
        ;* @brief If set the client instance will auto position users
        ; in a 180 degree circle using 3D-sound. This option is only
        ; available With #SOUNDSYSTEM_DSOUND.
        ; @see TT_SetUserPosition 
        ; @see TT_Enable3DSoundPositioning */
        #CLIENT_SNDOUTPUT_AUTO3DPOSITION  = $00000100
        ;* @brief If set the client instance will try to eliminate
         ; echo from speakers. To enable echo cancellation first make
         ; the client run on sound duplex mode by calling
         ; TT_InitSoundDuplexDevices() And afterwards call
         ; TT_EnableEchoCancellation(). */
        #CLIENT_SNDINPUT_AEC              = $00000200
        ;* @brief If set the client instance is running in sound
         ; duplex mode where multiple audio output streams are mixed
         ; into a single stream. This option must be enabled To
         ; support echo cancellation (#CLIENT_SNDINPUT_AEC). Call
         ; TT_InitSoundDuplexDevices() To enable duplex mode.*/
        #CLIENT_SNDINOUTPUT_DUPLEX        = $00000400
        ;* @brief If set the client instance is currently transmitting
         ; audio.  @see TT_EnableTransmission */
        #CLIENT_TX_AUDIO                  = $00001000
        ;* @brief If set the client instance is currently transmitting video.
         ; @see TT_EnableTransmission */
        #CLIENT_TX_VIDEO                  = $00002000
        ;* @brief If set the client instance is currently muxing
         ; audio streams into a single file. This is enabled by calling
         ; TT_StartRecordingMuxedAudioFile(). */
        #CLIENT_MUX_AUDIOFILE             = $00004000
        ;* @brief If set the client instance is currently transmitting
         ; a desktop window. A desktop window update is issued by calling
         ; TT_SendDesktopWindow(). The event 
         ; #WM_TEAMTALK_DESKTOPWINDOW_TRANSFER is triggered when a desktop
         ; window transmission completes. */
        #CLIENT_TX_DESKTOP                = $00008000
        ;* @brief If set the client instance is currently try to
         ; connect To a server, i.e. #TT_Connect has been called. */
        #CLIENT_CONNECTING                = $00010000
        ;* @brief If set the client instance is connected to a server,
         ; i.e. #WM_TEAMTALK_CON_SUCCESS event has been issued after
         ; doing a #TT_Connect. Valid commands in this state:
         ; #TT_DoLogin */
        #CLIENT_CONNECTED                 = $00020000
        ;* @brief Helper for #CLIENT_CONNECTING and #CLIENT_CONNECTED
         ; To see If #TT_Disconnect should be called. */
        #CLIENT_CONNECTION                = #CLIENT_CONNECTING | #CLIENT_CONNECTED
        ;* @brief If set the client instance is logged on to a
         ; server, i.e. got #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN event
         ; after issueing #TT_DoLogin. */
        #CLIENT_AUTHORIZED                = $00040000
        ;* @brief If set the client instance will try and connect to
         ; other users using peer To peer connections. Audio will be
         ; broadcast To users instead of forwarded through server
         ; (thereby increasing the bandwith usage).  Note that If
         ; #USERRIGHT_FORWARD_AUDIO is disabled And no peer To peer
         ; connection could be established, i.e. event
         ; #WM_TEAMTALK_CON_P2P was posted With failure, then Data
         ; cannot be transferred To a user. */
        #CLIENT_P2P_AUDIO                 = $00100000
        ;* @brief If set the client instance will try and connect to
         ; other users using peer To peer connections. Video will be
         ; broadcast To users instead of forwarded through server
         ; (thereby increasing the bandwith usage).  Note that If
         ; #USERRIGHT_FORWARD_VIDEO is disabled And no peer To peer
         ; connection could be established, i.e. event
         ; #WM_TEAMTALK_CON_P2P was posted With failure, then Data
         ; cannot be transferred To a user. */
        #CLIENT_P2P_VIDEO                 = $00200000
        ;* @brief Helper for #CLIENT_P2P_AUDIO and #CLIENT_P2P_VIDEO to see
         ; If the client instance is currently attempting P2P connections. */
        #CLIENT_P2P                       = #CLIENT_P2P_AUDIO | #CLIENT_P2P_VIDEO
        ;* @brief If set the client is currently streaming the audio
         ; of a media file. When streaming a video file the
         ; #CLIENT_STREAM_VIDEO flag is also typically set.
         ; @see TT_StartStreamingMediaFileToChannel() */
        #CLIENT_STREAM_AUDIO              = $00400000
        ;* @brief If set the client is currently streaming the video
;        of a media file. When streaming a video file the
;        #CLIENT_STREAM_AUDIO flag is also typically set.
        ; @see TT_StartStreamingMediaFileToChannel() */
        #CLIENT_STREAM_VIDEO              = $00800000
    EndEnumeration

    ;* @brief A bitmask based on #ClientFlag describing the local client 
     ; instance's current state.  */
    ;typedef UINT32 ClientFlags;
    
    CompilerSelect #PB_Compiler_OS
        CompilerCase #PB_OS_Windows
      CompilerIf #PB_Compiler_Processor=#PB_Processor_x86
      ImportC "..\lib\win\x86\TeamTalk4.lib"
      CompilerElse
        ImportC "..\lib\win\x64\TeamTalk4.lib"
      CompilerEndIf    
    CompilerEndSelect
    
    ;* @brief Get the DLL's version number. */
    TT_GetVersion()

CompilerIf #PB_Compiler_OS=#PB_OS_Windows
    ;* 
     ; @brief Create a new TeamTalk client instance where events are
     ; posted To a HWND.
;    *
     ; This function must be invoked before any other of the TT_*
     ; functions can be called. Call #TT_CloseTeamTalk To shutdown the
     ; TeamTalk client And release its resources.
;    *
     ; @param hWnd The window handle which will receive the events defined
     ; in #ClientEvent.
     ; @return A pointer To a new client instance. NULL If a failure occured.
     ; @see TT_CloseTeamTalk */
    TT_InitTeamTalk(hWnd.l);

    ;*
     ; @brief Replace the HWND passed As parameter To #TT_InitTeamTalk
     ; With this HWND.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param hWnd The new HWND which should receive event messages. */
    TT_SwapTeamTalkHWND(*lpTTInstance,
                                             hWnd.l)
CompilerEndIf

    ;* 
     ; @brief Create a new TeamTalk client instance where events are 
     ; 'polled' using #TT_GetMessage.
;    *
     ; This 'polled' method can be used by application which doesn't
     ; have a HWND, e.g. console applications.
;    *
     ; This function must be invoked before any other of the TT_*
     ; functions can be called. Call #TT_CloseTeamTalk To shutdown the
     ; TeamTalk client And release its resources.
;    *
     ; @return A pointer To a new client instance. NULL If a failure occured.
     ; @see TT_CloseTeamTalk */
    TT_InitTeamTalkPoll()

    ;* 
     ; @brief Close the TeamTalk client instance And release its
     ; resources.
;    *
     ; It is adviced To call this before closing the main application
     ; To ensure a proper shutdown.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @see TT_InitTeamTalk */
    TT_CloseTeamTalk(*lpTTInstance)

    ;*
     ; @brief Poll For events in the client instance.
     ; 
     ; On Windows a each client instance can send its events To a 
     ; HWND but events can also be polled using a timer using 
     ; @a TT_GetMessage.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; @param pMsg Pointer To a TTMessage instance which will hold the 
     ; events that has occured.
     ; @param pnWaitMs The amount of time To wait For the event. If NULL Or -1
     ; the function will block ForEver Or Until the Next event occurs.
     ; @return Returns TRUE If an event has occured otherwise FALSE.
     ; @see TT_InitTeamTalkPolled
     ; @see ClientEvent */
    TT_GetMessage(*lpTTInstance, 
                                       *pMsg,
                                       pnWaitMs.l)

    ;*
     ; @brief Get a bitmask describing the client's current state.
;    *
     ; Checks whether the client is connecting, connected, authorized,
     ; etc. The current state can be checked by And'ing the returned
     ; bitmask which is based on #ClientFlag.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @return A bitmask describing the current state (based on 
     ; #ClientFlag).
     ; @see ClientFlag */
     TT_GetFlags(*lpTTInstance)

     ;*
      ; @brief Set license information To disable trial mode.
 ;    *
      ; This function must be called before #TT_InitTeamTalk.
 ;    *
      ; @param szRegName The registration name provided by BearWare.dk.
      ; @param nRegKey The registration key provided by BearWare.dk.
      ; @return True If the provided registration is acceptable. */
     TT_SetLicenseInformation(szRegName.s,
                                                   nRegKey.l);
    ;* @} */

    ;* @addtogroup sounddevices
     ; @{ */

    ;*
     ; @brief Get the Default sound devices. 
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param lpnInputDeviceID The ID of the Default input device.
     ; @param lpnOutputDeviceID The ID of the Default output device.
     ; @see TT_InitSoundInputDevice
     ; @see TT_InitSoundOutputDevice */
    TT_GetDefaultSoundDevices(*lpTTInstance, 
                                                   lpnInputDeviceID.l, 
                                                   lpnOutputDeviceID.l)
    ;*
     ; @brief Get the Default sound devices For the specified sound system.
;    *
     ; @see TT_GetDefaultSoundDevices() */
    TT_GetDefaultSoundDevicesEx(nSndSystem.l, 
                                                     lpnInputDeviceID.l, 
                                                     lpnOutputDeviceID.l)

    ;*
     ; @brief Get information about input devices For audio recording. 
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; TT_InitTeamTalk.
     ; @param lpSoundDevices Array of SoundDevice-structs where lpnHowMany holds
     ; the size of the Array. Pass NULL As @a lpSoundDevices To query the 
     ; number of devices.
     ; @param lpnHowMany This is both an input And an output parameter. If 
     ; @a lpSoundDevices is NULL lpnHowMany will after the call hold the
     ; number of devices, otherwise it should hold the size of the
     ; @a lpSoundDevices Array.
     ; @see TT_GetDefaultSoundDevices
     ; @see TT_InitSoundInputDevice
     ; @see TT_InitSoundOutputDevice */
    TT_GetSoundInputDevices(*lpTTInstance, 
                                                 *lpSoundDevices,
                                                 lpnHowMany.l)

    ;* 
     ; @brief Get the List of sound output devices For playback. 
;    *
     ; The nDeviceID of the #SoundDevice struct should be passed To
     ; #TT_InitSoundOutputDevice.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpSoundDevices Array of SoundDevice-structs where @a lpnHowMany
     ; holds the size of the Array. Pass NULL As @a lpSoundDevices To query the 
     ; number of devices.
     ; @param lpnHowMany This is both an input And an output parameter. If 
     ; @a lpSoundDevices is NULL @a lpnHowMany will after the call hold the
     ; number of devices, otherwise it should hold the size of the
     ; @a lpSoundDevices Array.
     ; @see TT_GetDefaultSoundDevices 
     ; @see TT_InitSoundOutputDevice */
    TT_GetSoundOutputDevices(*lpTTInstance, 
                                                  *lpSoundDevices,
                                                  lpnHowMany.l)

    ;*
     ; @brief Initialize the sound input devices (For recording audio).
;    *
     ; The @a nDeviceID of the #SoundDevice should be used As @a 
     ; nInputDeviceID.
;    *
     ; Callling this function will set the flag #CLIENT_SNDINPUT_READY.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nInputDeviceID The @a nDeviceID of #SoundDevice extracted 
     ; through #TT_GetSoundInputDevices.
     ; @see SoundDevice
     ; @see TT_GetDefaultSoundDevices
     ; @see TT_GetSoundInputDevices
     ; @see TT_CloseSoundInputDevice
     ; @see TT_GetSoundInputLevel */
    TT_InitSoundInputDevice(*lpTTInstance, 
                                                 nInputDeviceID.l)

    ;* 
     ; @brief Initialize the sound output devices (For sound playback).
;    *
     ; The @a nDeviceID of the #SoundDevice should be used As @a 
     ; nOutputDeviceID.
;    *
     ; Callling this function will set the flag
     ; #CLIENT_SNDOUTPUT_READY.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nOutputDeviceID The @a nDeviceID of #SoundDevice extracted
     ; through #TT_GetSoundOutputDevices.
     ; @see SoundDevice
     ; @see TT_GetDefaultSoundDevices
     ; @see TT_GetSoundOutputDevices
     ; @see TT_CloseSoundOutputDevice */
    TT_InitSoundOutputDevice(*lpTTInstance, 
                                                  nOutputDeviceID.l)

    ;*
     ; @brief Enable duplex mode where multiple audio streams are
     ; mixed into a single stream using software.
;    *
     ; Duplex mode can @b ONLY be enabled on sound devices which
     ; support the same sample rate. Sound systems #SOUNDSYSTEM_WASAPI
     ; And #SOUNDSYSTEM_ALSA typically only support a single sample
     ; rate.  Check @c supportedSampleRates in #SoundDevice To see
     ; which sample rates are supported.
;    *
     ; Sound duplex mode is required For echo cancellation since sound
     ; input And output device must be synchronized. Also sound cards
     ; which does Not support multiple output streams should use
     ; duplex mode.
;    *
     ; If TT_InitSoundDuplexDevices() is successful the following
     ; flags will be set:
;    *
     ; - #CLIENT_SNDINOUTPUT_DUPLEX
     ; - #CLIENT_SNDOUTPUT_READY
     ; - #CLIENT_SNDINPUT_READY
;    *
     ; Call TT_CloseSoundDuplexDevices() To shut down duplex mode.
;    *
     ; Note that it is only the audio streams from users in the local
     ; client instance's current channel which will be mixed. If the
     ; local client instance calls TT_DoSubscribe() With
     ; #SUBSCRIBE_INTERCEPT_AUDIO on a user in another channel then
     ; the audio from this user will be started in a separate
     ; stream. The reason For this is that the other user may use a
     ; different audio codec.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nInputDeviceID The @a nDeviceID of #SoundDevice extracted 
     ; through #TT_GetSoundInputDevices.
     ; @param nOutputDeviceID The @a nDeviceID of #SoundDevice extracted
     ; through #TT_GetSoundOutputDevices.
     ; @see TT_InitSoundInputDevice()
     ; @see TT_InitSoundOutputDevice()
     ; @see TT_EnableEchoCancellation()
     ; @see TT_CloseSoundDuplexDevices() */
    TT_InitSoundDuplexDevices(*lpTTInstance, 
                                                   nInputDeviceID.l,
                                                   nOutputDeviceID.l)

    ;*
     ; @brief Shutdown the input sound device.
;    *
     ; Callling this function will clear the flag
     ; #CLIENT_SNDINPUT_READY.
;    *
     ; If the local client instance is running in duplex mode (flag
     ; #CLIENT_SNDINOUTPUT_DUPLEX is set) then trying To close the
     ; sound device will fail since duplex mode require that both
     ; input And output sound devices are active at the same
     ; time. Therefore in order To close sound devices running in
     ; duplex mode call TT_CloseSoundDuplexDevices().
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return If running in sound duplex mode (#CLIENT_SNDINOUTPUT_DUPLEX)
     ; then ensure To disable duplex mode prior To closing the sound device.
     ; @see TT_InitSoundInputDevice */
    TT_CloseSoundInputDevice(*lpTTInstance)

    ;*
     ; @brief Shutdown the output sound device.
;    *
     ; Callling this function will clear set the flag
     ; #CLIENT_SNDOUTPUT_READY.
;    *
     ; If the local client instance is running in duplex mode (flag
     ; #CLIENT_SNDINOUTPUT_DUPLEX is set) then trying To close the
     ; sound device will fail since duplex mode require that both
     ; input And output sound devices are active at the same
     ; time. Therefore in order To close sound devices running in
     ; duplex mode call TT_CloseSoundDuplexDevices().
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return If running in sound duplex mode (#CLIENT_SNDINOUTPUT_DUPLEX)
     ; then ensure To disable duplex mode prior To closing the sound device.
     ; @see TT_InitSoundOutputDevice */
    TT_CloseSoundOutputDevice(*lpTTInstance)

    ;*
     ; @brief Shut down sound devices running in duplex mode.
;    *
     ; Calling this function only applies If sound devices has been
     ; initialized With TT_InitSoundDuplexDevices().
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk. */
    TT_CloseSoundDuplexDevices(*lpTTInstance)

    ;*
     ; @brief Reinitialize sound system (in order To detect
     ; new/removed devices).
;    *
     ; When the TeamTalk client is first initialized all the sound
     ; devices are detected And stored in a List inside the client
     ; instance. If a user adds Or removes e.g. a USB sound device
     ; then it's not picked up automatically by the client
     ; instance. TT_RestartSoundSystem() can be used To reinitialize
     ; the sound system And thereby detect If sound devices have been
     ; removed Or added.
;    *
     ; In order To restart the sound system all sound devices in all
     ; client instances must be closed using TT_CloseSoundInputDevice(),
     ; TT_CloseSoundoutputDevice() And TT_CloseSoundDuplexDevices(). */
    TT_RestartSoundSystem()

    ;*
     ; @brief Perform a record And playback test of specified sound
     ; devices.
;    *
     ; Call TT_StopSoundLoopbackTest() To stop the loopback test.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nInputDeviceID Should be the @a nDeviceID extracted through 
     ; #TT_GetSoundInputDevices.
     ; @param nOutputDeviceID Should be the @a nDeviceID extracted through 
     ; #TT_GetSoundOutputDevices.
     ; @param nSampleRate The sample rate the client's recorder should 
     ; use.
     ; @param nChannels Number of channels To use, i.e. 1 = mono, 2 = stereo
     ; Note that echo cancellation, denoising And AGC is Not supported in
     ; stereo.
     ; @see TT_InitSoundInputDevice()
     ; @see TT_InitSoundOutputDevice()
     ; @see TT_InitSoundDuplexDevices()
     ; @see TT_StopSoundLoopbackTest */
    TT_StartSoundLoopbackTest(*lpTTInstance, 
                                                   nInputDeviceID.l, 
                                                   nOutputDeviceID.l,
                                                   nSampleRate.l,
                                                   nChannels.l)

    ;*
     ; @brief Perform a record And playback test of specified sound
     ; devices along With an audio configuration And ability To try
     ; echo cancellation.
;    *
     ; Both input And output devices MUST support the specified sample 
     ; rate since this loop back test uses duplex mode 
     ; ( @see TT_InitSoundDuplexDevices() ). Check out @c 
     ; supportedSampleRates of #SoundDevice To see which sample rates
     ; are supported.
;    *
     ; Call TT_StopSoundLoopbackTest() To stop the loopback
     ; test.
;    *
     ; This function is almost like TT_StartSoundLoopbackTest() except
     ; that it allows the use of #AudioConfig To enable AGC And echo
     ; cancellation. Note that AGC And echo cancellation can only be
     ; used in mono, i.e. @c nChannels = 1.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nInputDeviceID Should be the @a nDeviceID extracted through 
     ; #TT_GetSoundInputDevices.
     ; @param nOutputDeviceID Should be the @a nDeviceID extracted through 
     ; #TT_GetSoundOutputDevices.
     ; @param nSampleRate The sample rate the client's recorder should 
     ; use.
     ; @param nChannels Number of channels To use, i.e. 1 = mono, 2 = stereo.
     ; Note that echo cancellation, denoising And AGC is Not supported in
     ; stereo.
     ; @param lpAudioConfig The audio configuration To use, i.e. AGC 
     ; And denoising properties.
     ; @param bEchoCancel Whether To enable echo cancellation.
     ; @see TT_InitSoundInputDevice()
     ; @see TT_InitSoundOutputDevice()
     ; @see TT_InitSoundDuplexDevices()
     ; @see TT_StopSoundLoopbackTest() */
    TT_StartSoundLoopbackTestEx(*lpTTInstance, 
                                                     nInputDeviceID.l, 
                                                     nOutputDeviceID.l,
                                                     nSampleRate.l,
                                                     nChannels.l,
                                                     *lpAudioConfig.AudioConfig,
                                                     bEchoCancel.a)
    ;*
     ; @brief Stop recorder And playback test.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @see TT_InitSoundInputDevice
     ; @see TT_InitSoundOutputDevice
     ; @see TT_StartSoundLoopbackTest */
    TT_StopSoundLoopbackTest(*lpTTInstance)

    ;*
     ; @brief Get the volume level of the current recorded audio.
;    *
     ; The current level is updated at an interval specified in a channel's
     ; #AudioCodec.
;    *
     ; Note that the volume level will Not be available Until the
     ; client instance joins a channel, i.e. it knows what sample rate
     ; To use.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return Returns a value between #SOUND_VU_MIN And #SOUND_VU_MAX. */
    TT_GetSoundInputLevel(*lpTTInstance)

    ;* 
     ; @brief Set voice gaining of recorded audio. 
;    *
     ; The gain level ranges from #SOUND_GAIN_MIN To #SOUND_GAIN_MAX
     ; where #SOUND_GAIN_DEFAULT is no gain. So 100 is 1/10 of the
     ; original volume And 8000 is 8 times the original volume.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nLevel A value from #SOUND_GAIN_MIN To #SOUND_GAIN_MAX.
     ; @see TT_GetSoundInputGainLevel */
    TT_SetSoundInputGainLevel(*lpTTInstance, 
                                                   nLevel.l)

    ;*
     ; @brief Get voice gain level of outgoing audio
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return A value from #SOUND_GAIN_MIN To #SOUND_GAIN_MAX.
     ; @see TT_SetSoundInputGainLevel */
    TT_GetSoundInputGainLevel(*lpTTInstance)

    ;*
     ; @brief Set master volume. 
;    *
     ; If still Not loud enough use #TT_SetUserGainLevel.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nVolume A value from #SOUND_VOLUME_MIN To  #SOUND_VOLUME_MAX.
     ; @see TT_SetUserVolume */
    TT_SetSoundOutputVolume(*lpTTInstance, 
                                                 nVolume.l)

    ;*
     ; @brief Get master volume.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return Returns the master volume.
     ; @see SOUND_VOLUME_MAX
     ; @see SOUND_VOLUME_MIN
     ; @see TT_GetUserVolume */
    TT_GetSoundOutputVolume(*lpTTInstance)

    ;*
     ; @brief Set all users mute.
;    *
     ; To stop receiving audio from a user call #TT_DoUnsubscribe.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param bMuteAll Whether To mute Or unmute all users.
     ; @see CLIENT_SNDOUTPUT_MUTE */
    TT_SetSoundOutputMute(*lpTTInstance, 
                                               bMuteAll.a)

    ;*
     ; @brief Enable denoising of recorded audio.
;    *
     ; This call will enable/disable the #CLIENT_SNDINPUT_DENOISING
     ; flag. Denoising will Not be active If the local client instance
     ; is participating in a channel which uses a stereo #AudioCodec.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param bEnable TRUE To enable, otherwise FALSE.
     ; @see TT_SetDenoiseLevel() */
    TT_EnableDenoising(*lpTTInstance, 
                                            bEnable.a)

    ;*
     ; @brief Set the denoise level of recorded audio.
;    *
     ; Setting denoise level is only valid If TT_GetFlags() contains
     ; #CLIENT_SNDINPUT_DENOISING.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nLevel Maximum attenuation of the noise in dB. Negative value!
     ; Default value is -15.
     ; @see TT_EnableDenoising() */
    TT_SetDenoiseLevel(*lpTTInstance, 
                                            nLevel.l)

    ;*
     ; @brief Set the denoise level of recorded audio.
;    *
     ; Getting denoise level is only valid If TT_GetFlags() contains
     ; #CLIENT_SNDINPUT_DENOISING.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Maximum attenuation of the noise in dB. Negative value!
     ; @see TT_SetDenoiseLevel() */
    TT_GetDenoiseLevel(*lpTTInstance)

    ;*
     ; @brief Enable/disable acoustic echo cancellation (AEC).
;    *
     ; In order To enable echo cancellation mode the local client
     ; instance must first be set in sound duplex mode by calling
     ; TT_InitSoundDuplexDevices(). This is because the echo canceller
     ; must first mixed all audio streams into a single stream And
     ; have then run in synch With the input stream. After calling
     ; TT_InitSoundDuplexDevices() the flag #CLIENT_SNDINOUTPUT_DUPLEX
     ; will be set.
;    *
     ; For echo cancellation To work the sound input And output device
     ; must be the same sound card since the input And output stream
     ; must be completely synchronized. Also it is recommended To also
     ; enable denoising And AGC For better echo cancellation by calling
     ; TT_EnableDenoising() And TT_EnableAGC() respectively. Using an 
     ; #AudioConfig on a #Channel can also be use To automatically
     ; enable denoising And AGC.
;    *
     ; Echo cancellation will Not be active If the local client
     ; instance is participating in a channel which uses a stereo
     ; #AudioCodec.
;    *
     ; After calling TT_EnableEchoCancellation() the flag
     ; #CLIENT_SNDINPUT_AEC will be set.
;    *
     ; Note that Windows Mobile/CE doesn't support echo cancellation.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param bEnable Whether To enable Or disable echo callation.
     ; @see TT_EnableDenoising()
     ; @see TT_EnableAGC()
     ; @see TT_InitSoundInputDevice()
     ; @see TT_InitSoundOutputDevice() */
    TT_EnableEchoCancellation(*lpTTInstance,
                                                   bEnable.a);

    ;* 
     ; @brief Enable Automatic Gain Control
;    *
     ; Each #Channel can also be configured To automatically enable
     ; the local client instance To enable AGC by specifying the @a
     ; bEnableAGC member of #AudioConfig.
;    *
     ; AGC will Not be active If the local client instance is
     ; participating in a channel which uses a stereo #AudioCodec.
;    *
     ; Note that Windows Mobile/CE doesn't support AGC.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param bEnable Whether To enable AGC.
     ; @see CLIENT_SNDINPUT_AGC
     ; @see TT_SetAGCSettings */
    TT_EnableAGC(*lpTTInstance, 
                                      bEnable.a)

    ;* 
     ; @brief Set Automatic Gain Control (AGC) settings.
;    *
     ; Since microphone volumes may vary AGC can be used To adjust a signal
     ; To a reference volume. That way users will speak at the same volume
     ; level.
;    *
     ; Calling TT_SetAGCSettings() is only valid If TT_GetFlags() contains
     ; #CLIENT_SNDINPUT_AGC.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nGainLevel A value from 0 To 32768. Default is 8000.
     ; @param nMaxIncrement Used so volume
     ; should Not be amplified too quickly (maximal gain increase in dB/second).
     ; Default is 12.
     ; @param nMaxDecrement Negative value! Used so volume
     ; should Not be attenuated too quickly (maximal gain decrease in
     ; dB/second). Default is -40.
     ; @param nMaxGain Ensure volume doesn't become too loud (maximal gain
     ; in dB). Default is 30.
     ; @see TT_EnableAGC */
    TT_SetAGCSettings(*lpTTInstance, 
                                           nGainLevel.l, 
                                           nMaxIncrement.l,
                                           nMaxDecrement.l,
                                           nMaxGain.l)

    ;* 
     ; @brief Get Automatic Gain Control settings.
;    *
     ; Calling TT_GetAGCSettings() is only valid If TT_GetFlags() contains
     ; #CLIENT_SNDINPUT_AGC.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpnGainLevel A value from 0 To 32768.
     ; @param lpnMaxIncrement Used so volume
     ; should Not be amplified too quickly (maximal gain increase in dB/second).
     ; @param lpnMaxDecrement Negative value! Used so volume
     ; should Not be attenuated too quickly (maximal gain decrease in 
     ; dB/second).
     ; @param lpnMaxGain Ensure volume doesn't become too loud (maximal gain
     ; in dB).
     ; @see TT_EnableAGC */
    TT_GetAGCSettings(*lpTTInstance, 
                                           lpnGainLevel.l, 
                                           lpnMaxIncrement.l,
                                           lpnMaxDecrement.l,
                                           lpnMaxGain.l)

    ;* 
     ; @brief Enable automatically position users using 3D-sound.
;    *
     ; Note that 3d-sound does Not work If sound is running in duplex
     ; mode (#CLIENT_SNDINOUTPUT_DUPLEX).
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param bEnable TRUE To enable, otherwise FALSE.
     ; @see TT_SetUserPosition */
    TT_Enable3DSoundPositioning(*lpTTInstance, 
                                                     bEnable.a)

    ;* 
     ; @brief Automatically position users using 3D-sound.
;    *
     ; Note that 3d-sound does Not work If sound is running in duplex
     ; mode (#CLIENT_SNDINOUTPUT_DUPLEX).
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @see TT_SetUserPosition */
    TT_AutoPositionUsers(*lpTTInstance)

    ;*
     ; @brief Enable/disable access To user's raw audio.
;    *
     ; With audio block event enabled all audio which has been played
     ; will be accessible by calling TT_AcquireUserAudioBlock(). Every
     ; time a new #AudioBlock is available the event
     ; #WM_TEAMTALK_USER_AUDIOBLOCK is generated.
     ; 
     ; @see TT_AcquireUserAudioBlock()
     ; @see TT_ReleaseUserAudioBlock()
     ; @see WM_TEAMTALK_USER_AUDIOBLOCK */
    TT_EnableAudioBlockEvent(*lpTTInstance,
                                                  bEnable.a)

    ;* @} */

    ;* @addtogroup transmission
     ; @{ */

    ;*
     ; @brief Enable voice activation.
;    *
     ; The client instance will start transmitting audio If the recorded audio
     ; level is above Or equal To the voice activation level set by
     ; #TT_SetVoiceActivationLevel. Once the voice activation level is reached
     ; the event #WM_TEAMTALK_VOICE_ACTIVATION is posted.
;    *
     ; The current volume level can be queried calling
     ; #TT_GetSoundInputLevel.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param bEnable TRUE To enable, otherwise FALSE.
     ; @see CLIENT_SNDINPUT_VOICEACTIVATION
     ; @see TT_SetVoiceActivationStopDelay */
    TT_EnableVoiceActivation(*lpTTInstance, 
                                                  bEnable.a)

    ;* 
     ; @brief Set voice activation level.
;    *
     ; The current volume level can be queried calling
     ; #TT_GetSoundInputLevel.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nLevel Must be between #SOUND_VU_MIN And #SOUND_VU_MAX
     ; @see TT_EnableVoiceActivation
     ; @see TT_GetVoiceActivationLevel
     ; @see TT_SetVoiceActivationStopDelay */
    TT_SetVoiceActivationLevel(*lpTTInstance, 
                                                    nLevel.l)

    ;* 
     ; @brief Get voice activation level.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns A value between #SOUND_VU_MIN And #SOUND_VU_MAX
     ; @see TT_EnableVoiceActivation
     ; @see TT_SetVoiceActivationLevel */
    TT_GetVoiceActivationLevel(*lpTTInstance)

    ;*
     ; @brief Set the delay of when voice activation should be stopped.
;    *
     ; When TT_GetSoundInputLevel() becomes higher than the specified
     ; voice activation level the client instance will start
     ; transmitting Until TT_GetSoundInputLevel() becomes lower than
     ; the voice activation level, plus a delay. This delay is by
     ; Default set To 1500 msec but this value can be changed by
     ; calling TT_SetVoiceActivationStopDelay().
;    *
     ; @see TT_EnableVoiceActivation
     ; @see TT_SetVoiceActivationLevel */
    TT_SetVoiceActivationStopDelay(*lpTTInstance,
                                                        nDelayMSec.l)

    ;*
     ; @brief Get the delay of when voice active state should be disabled.
;    *
     ; @return The number of miliseconds before voice activated state
     ; should be turned back To inactive.
;    *
     ; @see TT_SetVoiceActivationStopDelay
     ; @see TT_EnableVoiceActivation
     ; @see TT_SetVoiceActivationLevel */
    TT_GetVoiceActivationStopDelay(*lpTTInstance)

    ;*
     ; @brief Store audio conversations To a single file.
;    *
     ; Unlike TT_SetUserAudioFolder(), which stores users' audio
     ; streams in separate files, TT_StartRecordingMuxedAudioFile()
     ; muxes the audio streams into a single file.
;    *
     ; The audio streams, which should be muxed together, are
     ; required To use the same audio codec. In most cases this is
     ; the audio codec of the channel where the user is currently
     ; participating (i.e. @c codec member of #Channel).
;    *
     ; If the user changes To a channel which uses a different audio
     ; codec then the recording will Continue but simply be silent
     ; Until the user again joins a channel With the same audio codec
     ; As was used For initializing muxed audio recording.
;    *
     ; Calling TT_StartRecordingMuxedAudioFile() will enable the
     ; #CLIENT_MUX_AUDIOFILE flag from TT_GetFlags().
;    *
     ; Call TT_StopRecordingMuxedAudioFile() To stop recording. Note
     ; that only one muxed audio recording can be active at the same
     ; time.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpAudioCodec The audio codec which should be used As
     ; reference For muxing users' audio streams. In most situations
     ; this is the #AudioCodec of the current channel, i.e.
     ; TT_GetMyChannelID().
     ; @param szAudioFileName The file To store audio To, e.g. 
     ; C:\\MyFiles\\Conf.mp3.
     ; @param uAFF The audio format which should be used in the recorded
     ; file. The muxer will convert To this format.
;    *
     ; @see TT_SetUserAudioFolder()
     ; @see TT_StopRecordingMuxedAudioFile() */
    TT_StartRecordingMuxedAudioFile(*lpTTInstance,
                                                         *lpAudioCodec.AudioCodec,
                                                         szAudioFileName.s,
                                                         uAFF.l)

    ;*
     ; @brief Stop an active muxed audio recording.
;    *
     ; A muxed audio recording started With
     ; TT_StartRecordingMuxedAudioFile() can be stopped using this
     ; function.
;    *
     ; Calling TT_StopRecordingMuxedAudioFile() will clear the
     ; #CLIENT_MUX_AUDIOFILE flag from TT_GetFlags().
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
;    *
     ; @see TT_StartRecordingMuxedAudioFile() */
    TT_StopRecordingMuxedAudioFile(*lpTTInstance)
    ;* @} */

    ;* @addtogroup videocapture
     ; @{ */

    ;*
     ; @brief Get the List of devices available For video capture.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param lpVideoDevices Array of VideoCaptureDevice-stucts where
     ; @a lpnHowMany hold the size of the Array. Pass NULL To query
     ; the number of devices.
     ; @param lpnHowMany This is both an input And output
     ; parameter. If @a lpVideoDevices is NULL @a lpnHowMany will after
     ; the call hold the number of devices, otherwise it should hold
     ; the size of the @a lpVideoDevices Array.
     ; @see TT_InitVideoCaptureDevice */
    TT_GetVideoCaptureDevices(*lpTTInstance,
                                                   *lpVideoDevices,
                                                   lpnHowMany.l)

    ;*
     ; @brief Initialize a video capture device.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param szDeviceID The device idenfier @a szDeviceID of #VideoCaptureDevice.
     ; @param lpCaptureFormat The capture format To use,
     ; i.e. frame-rate, resolution And picture format.
     ; @param lpVideoCodec Video codec To use For transmission. Use NULL Or set 
     ; @a nCodec of #VideoCodec To #NO_CODEC If capture device should only be 
     ; used For testing locally. 
     ; @see TT_GetVideoCaptureDevices
     ; @see TT_CloseVideoCaptureDevice
     ; @see TT_EnableTransmission */
    TT_InitVideoCaptureDevice(*lpTTInstance,
                                                   szDeviceID.s,
                                                   *lpCaptureFormat.CaptureFormat,
                                                   *lpVideoCodec.VideoCodec)
    ;*
     ; @brief Close a video capture device.
;    *
     ; @see TT_InitVideoCaptureDevice */
    TT_CloseVideoCaptureDevice(*lpTTInstance)

CompilerIf #PB_Compiler_OS=#PB_OS_Windows
    ;*
     ; @brief Paint user's video frame using a Windows' DC (device
     ; context).
;    *
     ; Same As calling TT_PaintVideoFrameEx() like this:
;    *
;       @verbatim
;       TT_PaintVideoFrameEx(lpTTInstance, nUserID, hDC, 
;                            XDest, YDest, nDestWidth,
;                            nDestHeight, 0, 0, 
;                            src_bmp_width, src_bmp_height);
;       @endverbatim
;    *
     ; @c src_bmp_width And @c src_bmp_height are extracted internally
     ; from the source image. */
    TT_PaintVideoFrame(*lpTTInstance,
                                            nUserID.l,
                                            hDC.l,
                                            XDest.l,
                                            YDest.l,
                                            nDestWidth.l,
                                            nDestHeight.l)

    ;* 
     ; @brief Paint user's video frame using a Windows' DC (device
     ; context).
;    *
     ; An application can either paint using #TT_GetUserVideoFrame
     ; which provides a raw RGB32 Array of the image Or the
     ; application can ask the client instance To paint the image
     ; using this function.
;    *
     ; Typically this paint operation will be called in the WM_PAINT
     ; message. Here is how the client instance paints internally:
;    *
;        @verbatim
;        StretchDIBits(hDC, nPosX, nPosY, nWidth, nHeight, XSrc, YSrc, 
;                      nSrcWidth, nSrcHeight, frame_buf, &bmi,
;                      DIB_RGB_COLORS, SRCCOPY);
;        @endverbatim 
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID. 0 for local user.
     ; @param hDC The handle To the Windows device context.
     ; @param XDest Coordinate of left corner where To start painting.
     ; @param YDest Coordinate Or top corner where To start painting.
     ; @param nDestWidth The width of the image.
     ; @param nDestHeight The height of the image.
     ; @param XSrc The left coordinate in the source bitmap of where
     ; To start reading.
     ; @param YSrc The top left coordinate in the source bitmap of where
     ; To start reading.
     ; @param nSrcWidth The number of width pixels To Read from source bitmap.
     ; @param nSrcHeight The number of height pixels To Read from source bitmap.
     ; @see TT_GetUserVideoFrame */
    TT_PaintVideoFrameEx(*lpTTInstance,
                                              nUserID.l,
                                              hDC.l,
                                              XDest.l,
                                              YDest.l,
                                              nDestWidth.l,
                                              nDestHeight.l,
                                              XSrc.l,
                                              YSrc.l,
                                              nSrcWidth.l,
                                              nSrcHeight.l)
CompilerEndIf
    
    ;*
     ; @brief Get Or query the raw RGB32 bitmap Data of a user's video frame.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID. 0 for local user.
     ; @param lpPicBuffer A pointer To a preallocated buffer of the size 
     ; specified by @a nPicBufSize. Pass NULL To query the user's video format
     ; which will put in @a lpCaptureFormat.
     ; @param nPicBufSize The size in bytes of @a lpPicBuffer. The size must be
     ; width ; height ; 4. Use the @a lpCaptureFormat parameter To get the width
     ; And height. Ignored If @a lpPicBuffer is NULL.
     ; @param lpCaptureFormat If Not NULL the user's video frame format will
     ; be filled in this parameter. Use this information To calculate the size
     ; required of the @a lpPicBuffer parameter. */
    TT_GetUserVideoFrame(*lpTTInstance,
                                              nUserID.l,
                                              *lpPicBuffer,
                                              nPicBufSize.l,
                                              *lpCaptureFormat.CaptureFormat)

    ;* @brief Extract a user's video frame by making TeamTalk
     ; allocate the image buffer.
;    *
     ; Unlike TT_GetUserVideoFrame() this function does Not require
     ; that the user preallocates a buffer which will contain the
     ; image Data. Instead the image buffer is allocated in
     ; internally. REMEMBER, however, To call
     ; TT_ReleaseUserVideoFrame() when the image has been processed so
     ; the resources allocated by TeamTalk can be released.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID. 0 for local user.
     ; @param lpVideoFrame The struct which will contain the image Data. Note 
     ; that it's the @a frameBuffer member of #VideoFrame which will contain 
     ; the image Data allocated internally by TeamTalk.
     ; @return Returns TRUE If a video frame was successfully put in the 
     ; @a lpVideoFrame parameter.
     ; @see TT_GetUserVideoFrame
     ; @see TT_ReleaseUserVideoFrame */
    TT_AcquireUserVideoFrame(*lpTTInstance,
                                                  nUserID.l,
                                                  *lpVideoFrame.VideoFrame)

    ;* @brief Delete a user's video frame, acquired through
     ; TT_AcquireUserVideoFrame(), so its allocated resources can be
     ; released.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID. 0 for local user.
     ; @return Returns TRUE If a video frame was successfully put in the 
     ; @a lpVideoFrame parameter.
     ; @see TT_AcquireUserVideoFrame
     ; @see TT_GetUserVideoFrame */
    TT_ReleaseUserVideoFrame(*lpTTInstance,
                                                  nUserID.l)
    ;* @} */

    ;* @addtogroup transmission
     ; @{ */

    ;*
     ; @brief Start/stop transmitting audio Or video Data.
;    *
     ; To check If transmission of either audio Or video is enabled
     ; call #TT_GetFlags And check bits #CLIENT_TX_AUDIO And
     ; #CLIENT_TX_VIDEO.
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param uTxType A bitmask of the Data types To enable/disable
     ; transmission of.
     ; @param bEnable Enable/disable transmission of bits in mask. */
    TT_EnableTransmission(*lpTTInstance,
                                               uTxType.l,
                                               bEnable.a)

    ;* 
     ; @brief Check If the client instance is currently transmitting.
;    *
     ; This call also checks If transmission is ongoing due To voice
     ; activation.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param uTxType A mask specifying whether the client instance is 
     ; currently transmitting the given #TransmitType.
     ; @see TT_EnableTransmission
     ; @see TT_EnableVoiceActivation */
    TT_IsTransmitting(*lpTTInstance,
                                           uTxType.l)

    ;* 
     ; @brief Stream a wave-file To a user in another channel. Only an
     ; administrators can use this function.
;    *
     ; The event #WM_TEAMTALK_STREAM_AUDIOFILE_USER is called when
     ; audio file is started And stopped.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user To transmit To. The user cannot be
     ; in the same channel As the local client instance.
     ; @param szAudioFilePath Path To .wav file. The format of the .wav file
     ; must be 16-bit PCM uncompressed. Use <a href="http://audacity.sourceforge.net">
     ; Audacity</a> To convert To proper file format.
     ; @see TT_StopStreamingAudioFileToUser */
    TT_StartStreamingAudioFileToUser(*lpTTInstance,
                                                          nUserID.l,
                                                          szAudioFilePath.s)

    ;*
     ; @brief Stop transmitting audio file.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The ID of the user being transmitted To.
     ; @see TT_StartStreamingAudioFileToUser */
    TT_StopStreamingAudioFileToUser(*lpTTInstance,
                                                         nUserID.l)

    ;* 
     ; @brief Stream audio file To current channel.
     ; 
     ; Currently it is only possible To stream To the channel which the 
     ; local client instance is participating in.
;    *
     ; When streaming To the current channel it basically replaces the
     ; microphone input With a .wav file. Note that it is Not possible
     ; To stream a .wav file To a single user in the current channel.
;    *
     ; The event #WM_TEAMTALK_STREAM_AUDIOFILE_CHANNEL is posted when audio
     ; file is being processed.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nChannelID Pass #TT_GetMyChannelID. Transmitting To other 
     ; channels is currently Not supported.
     ; @param szAudioFilePath Path To .wav file. The format of the .wav file
     ; must be 16-bit PCM uncompressed. Use <a href="http://audacity.sourceforge.net">
     ; Audacity</a> To convert To proper file format.
     ; @see TT_StartStreamingAudioFileToUser
     ; @see TT_StopStreamingAudioFileToChannel */
    TT_StartStreamingAudioFileToChannel(*lpTTInstance,
                                                             nChannelID.l,
                                                             szAudioFilePath.s)

    ;*
     ; @brief Stop streaming audio file To current channel.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nChannelID Pass #TT_GetMyChannelID. */
    TT_StopStreamingAudioFileToChannel(*lpTTInstance,
                                                            nChannelID.l)
    ;*
     ; @brief Stream media file To channel, e.g. avi-, wav- Or MP3-file.
;    *
     ; This function is meant As a replacement For
     ; TT_StartStreamingAudioFileToChannel() since it can also stream
     ; wave-files.
;    *
     ; Call TT_GetMediaFileInfo() To get the properties of a media
     ; file, i.e. audio And video format.
;    *
     ; When a media file is being streamed it will replace the
     ; microphone And video input. Therefore calling
     ; TT_EnableTransmission() will have no effect.
;    *
     ; The event #WM_TEAMTALK_STREAM_MEDIAFILE_CHANNEL is called when
     ; the media file starts streaming. The flags #CLIENT_STREAM_AUDIO
     ; And/Or #CLIENT_STREAM_VIDEO will be set If the call is successful.
;    *
     ; It is important For the users who are receiving the streamed media file
     ; To increase their media playback buffer. This is because a streamed
     ; media file will generate bigger chunks of Data unlike microphone And 
     ; video capture devices which run in realtime. Use 
     ; TT_SetUserMediaBufferSize() To change the size of a user's media 
     ; buffer.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param szMediaFilePath File path To media file.
     ; @param lpVideoCodec If video file then specify output codec properties 
     ; here, otherwise NULL.
     ; @param uTxType Specify whether audio, video Or both should be streamed
     ; To channel. If #TRANSMIT_AUDIO is specified then the flag 
     ; #CLIENT_STREAM_AUDIO will be set. If #TRANSMIT_VIDEO is specified then
     ; the flag #CLIENT_STREAM_VIDEO is set.
;    *
     ; @see TT_StopStreamingMediaFileToChannel() */
    TT_StartStreamingMediaFileToChannel(*lpTTInstance,
                                                             szMediaFilePath.s,
                                                              *lpVideoCodec.VideoCodec,
                                                             uTxType.l)
    ;*
     ; @brief Stop streaming media file To channel.
;    *
     ; This will clear the flags #CLIENT_STREAM_AUDIO
     ; And/Or #CLIENT_STREAM_VIDEO.
;    *
     ; @see TT_StartStreamingMediaFileToChannel() */
    TT_StopStreamingMediaFileToChannel(*lpTTInstance)

    ;*
     ; @brief Get the properties of a media file.
;    *
     ; Use this function To determine the audio And video properties of
     ; a media file, so the user knows what can be streamed.
;    *
     ; @see TT_StartStreamingMediaFileToChannel() */
    TT_GetMediaFileInfo(szMediaFilePath.s,
                                             *pMediaFileInfo.MediaFileInfo)

    ;* @} */

    ;* @addtogroup desktopshare
     ; @{ */

    ;*
     ; @brief Transmit a desktop window (bitmap) To users in the same
     ; channel.
;    *
     ; When TT_SendDesktopWindow() is called the first time a new
     ; desktop session will be started. To update the current desktop
     ; session call TT_SendDesktopWindow() again once the previous
     ; desktop transmission has finished. Tracking progress of the
     ; current desktop transmission is done by checking For the
     ; #WM_TEAMTALK_DESKTOPWINDOW_TRANSFER event. While the desktop
     ; transmission is active the flag #CLIENT_TX_DESKTOP will be set
     ; on the local client instance.
;    *
     ; If the desktop window (bitmap) changes size (width/height) Or
     ; format a new desktop session will be started. Also If the user
     ; changes channel a new desktop session will be started. Check @c
     ; nSessionID of #DesktopWindow To see If a new desktop session is
     ; started Or the #WM_TEAMTALK_USER_DESKTOPWINDOW event.
;    *
     ; Remote users will get the #WM_TEAMTALK_USER_DESKTOPWINDOW event
     ; And can call TT_GetUserDesktopWindow() To retrieve the desktop
     ; window.
     ; 
     ; @note
     ; Requires server version 4.3.0.1490 Or later.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param lpBitmap Pointer To bitmap buffer.
     ; @param nBitmapSize Size of bitmap buffer @c lpBitmap in bytes. The size 
     ; of the bitmap can be calculated using the #DesktopWindow-struct's 
     ; @c nBytesPerLine multiplied by the @c nHeight.
     ; @param lpDesktopWindow Properties of the bitmap. Set the @c nSessionID 
     ; property To 0.
     ; @param nConvertBmpFormat Before transmission convert the bitmap To this 
     ; format.
     ; @return TRUE If desktop window is queued For transmission. FALSE If 
     ; @c nBitmapSize is invalid Or If a desktop transmission is already 
     ; active.
     ; @return -1 on error. 0 If bitmap has no changes. Greater than 0 on 
     ; success.
     ; @see TT_CloseDesktopWindow()
     ; @see TT_SendDesktopCursorPosition() */
    TT_SendDesktopWindow(*lpTTInstance,
                                               *lpBitmap, 
                                               nBitmapSize.l,
                                               *lpDesktopWindow.DesktopWindow,
                                               nConvertBmpFormat.l)

    ;*
     ; @brief Close the current desktop session.
;    *
     ; Closing the desktop session will cause the users receiving the
     ; current desktop session To see the desktop session ID change To
     ; 0 in the #WM_TEAMTALK_USER_DESKTOPWINDOW event.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. */
    TT_CloseDesktopWindow(*lpTTInstance)

    ;*
     ; @brief Get RGB values of the palette For the bitmap format.
;    *
     ; This currently only applies To bitmaps of format #BMP_RGB8_PALETTE.
;    *
     ; Note that the pointer returned is non-const which means the
     ; palette can be overwritten With a custom palette. The custom
     ; palette will then be used internally during bitmap
     ; conversion.
;    *
     ; @param nBmpPalette The bitmap format. Currently only #BMP_RGB8_PALETTE
     ; is supported.
     ; @param nIndex The index in the color table of the RGB values To 
     ; extract.
     ; @return Pointer To RGB colors. First byte is Red, second Blue And 
     ; third Green. Returns NULL If the color-index is invalid. */
    TT_Palette_GetColorTable(nBmpPalette.l,
                                                            nIndex.l)
CompilerIf #PB_Compiler_OS=#PB_OS_Windows

    ;* @brief Get the handle (HWND) of the window which is currently
     ; active (focused) on the Windows desktop. */
    TT_Windows_GetDesktopActiveHWND()

    ;* @brief Get the handle (HWND) of the Windows desktop (full desktop). */
    TT_Windows_GetDesktopHWND()

    ;* @brief Enumerate all the handles (@c HWND) of visible
     ; windows. Increment @c nIndex Until the function returns
     ; FALSE. Use TT_Windows_GetWindow() To get information about each
     ; window. */
    TT_Windows_GetDesktopWindowHWND(nIndex.l,
                                                         lpHWnd.l)

    ;*
     ; @brief A struct which describes the properties of a window
     ; which can be Shared.
     ; @see TT_Windows_GetDesktopWindowHWND()
     ; @see TT_Windows_GetWindow() */
    Structure ShareWindow
        ;* @brief The Windows handle of the window. */
        hWnd.l
        ;* @brief X coordinate of the window relative to the Windows desktop. */
        nWndX.l
        ;* @brief Y coordinate of the window relative to the Windows desktop. */
        nWndY.l
        ;* @brief The width in pixels of the window. */
        nWidth.l
        ;* @brief The height in pixels of the window. */
        nHeight.l
        ;* @brief The title of the window. */
        szWindowTitle.s{#TT_STRLEN}
    EndStructure

    ;*
     ; @brief Get the properties of a window from its window handle (HWND). */
    TT_Windows_GetWindow(hWnd.l,
                                              *lpShareWindow.ShareWindow)

    ;*
     ; @brief Transmit the specified window in a desktop session.
;    *
     ; Same As TT_SendDesktopWindow() except the properties For the
     ; #DesktopWindow are extracted automatically.
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param hWnd Windows handle For the window To transmit.
     ; @param nBitmapFormat Bitmap format To use For the transmitted image.
     ; @param nDesktopProtocol The protocol To use For transmitting the image.
     ; @return See TT_SendDesktopWindow(). */
    TT_SendDesktopWindowFromHWND(*lpTTInstance,
                                                       hWnd.l, 
                                                       nBitmapFormat.l,
                                                       nDesktopProtocol.l)
    
    ;*
     ; @brief Paint user's desktop window using a Windows' DC (device
     ; context).
;    *
     ; Same As calling TT_PaintDesktopWindowEx() like this:
;    *
;        @verbatim
;        TT_PaintDesktopWindowEx(lpTTInstance, nUserID, hDC, 
;                                XDest, YDest, nDestWidth,
;                                nDestHeight, 0, 0, 
;                                'src_bmp_width', 'src_bmp_height');
;        @endverbatim
;    *
     ; @c src_bmp_width And @c src_bmp_height are extracted internally
     ; from the source image. */
    TT_PaintDesktopWindow(*lpTTInstance,
                                               nUserID.l,
                                               hDC.l,
                                               XDest.l,
                                               YDest.l,
                                               nDestWidth.l,
                                               nDestHeight.l)

    ;*
     ; @brief Paint user's desktop window using a Windows' DC (device
     ; context).
;    *
     ; An application can either paint a bitmap by using
     ; TT_GetUserDesktopWindow() which provides a pointer To a bitmap
     ; Or the application can ask the client instance To paint the
     ; image using this function.
;    *
     ; Typically this paint operation will be called in the WM_PAINT
     ; message. Here is how the client instance paints internally:
;    *
;        @verbatim
;        StretchDIBits(hDC, nPosX, nPosY, nWidth, nHeight, XSrc, YSrc, 
;                      nSrcWidth, nSrcHeight, frame_buf, &bmi,
;                      DIB_RGB_COLORS, SRCCOPY);
;        @endverbatim 
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID.
     ; @param hDC The handle To the Windows device context.
     ; @param XDest Coordinate of left corner where To start painting.
     ; @param YDest Coordinate Or top corner where To start painting.
     ; @param nDestWidth The width of the image.
     ; @param nDestHeight The height of the image.
     ; @param XSrc The left coordinate in the source bitmap of where
     ; To start reading.
     ; @param YSrc The top left coordinate in the source bitmap of where
     ; To start reading.
     ; @param nSrcWidth The number of width pixels To Read from source bitmap.
     ; @param nSrcHeight The number of height pixels To Read from source bitmap.
     ; @return TRUE on success. FALSE on error, e.g. If user doesn't exist.
     ; @see TT_GetUserDesktopWindow() */
    TT_PaintDesktopWindowEx(*lpTTInstance,
                                                 nUserID.l,
                                                 hDC.l,
                                                 XDest.l,
                                                 YDest.l,
                                                 nDestWidth.l,
                                                 nDestHeight.l,
                                                 XSrc.l,
                                                 YSrc.l,
                                                 nSrcWidth.l,
                                                 nSrcHeight.l)
CompilerEndIf

CompilerIf #PB_Compiler_OS=#PB_OS_MacOS

    ;*
     ; @brief A struct which describes the properties of a window
     ; which can be Shared.
     ; @see TT_MacOS_GetWindow()
     ; @see TT_MacOS_GetWindowFromWindowID() */
    Structure ShareWindow
            ;* @brief The CGWindowID */
        nWindowID.q
        ;* @brief X coordinate of window. */
        nWindowX.l
        ;* @brief Y coordinate of window. */
        nWindowY.l
        ;* @brief The width of the window. */
        nWidth.l
        ;* @brief The height of the window. */
        nHeight.l
        ;* @brief The title of the window. */
        szWindowTitle.s{#TT_STRLEN}
        ;* @brief The PID of the owning process. */
        nPID.q
    EndStructure

    ;* @brief Enumerate all windows on the desktop. Increment @c
     ; nIndex Until the function returns FALSE. Use
     ; TT_MacOS_GetWindowFromWindowID() To get information about the
     ; window, e.g. title, dimensions, etc. */
    TT_MacOS_GetWindow(nIndex.l,
                                            *lpShareWindow.ShareWindow)

    ;* @brief Get information about a window by passing its handle
     ; (@c CGWindowID). @see TT_MacOS_GetWindow() */
    TT_MacOS_GetWindowFromWindowID(nWindowID.q,
                                                        *lpShareWindow.ShareWindow)

    ;*
     ; @brief Transmit the specified window in a desktop session.
;    *
     ; Same As TT_SendDesktopWindow() except the properties For the
     ; #DesktopWindow are extracted automatically.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nWindowID The handle of the window which should be converted To
     ; bitmap And sent To the server.
     ; @param nBitmapFormat Bitmap format To use For the transmitted image.
     ; @param nDesktopProtocol The protocol To use For transmitting the image.
     ; @return See TT_SendDesktopWindow(). */
    TT_SendDesktopFromWindowID(*lpTTInstance,
                                                     nWindowID.q, 
                                                     nBitmapFormat.l,
                                                     nDesktopProtocol.l)
CompilerEndIf

    ;*
     ; @brief Send the position of mouse cursor To users in the same channel.
;    *
     ; It's only possible to send the mouse cursor position if there's
     ; a desktop session which is currently active.
     ; 
     ; @note
     ; Requires server version 4.3.0.1490 Or later.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID For now set To 0.
     ; @param nPosX X coordinate of mouse cursor. Max is 65535.
     ; @param nPosY Y coordinate of mouse cursor. Max is 65535.
     ; @see TT_SendDesktopWindow() */
    TT_SendDesktopCursorPosition(*lpTTInstance,
                                                      nUserID.l,
                                                      nPosX.l,
                                                      nPosY.l)
    ;* 
     ; @brief Send a mouse Or keyboard event To a Shared desktop window.
;    *
     ; If a user is sharing a desktop window it's possible for a
     ; remote user To take control of mouse And keyboard input on the
     ; remote computer. Read section @ref txdesktopinput on how To
     ; transmit desktop input To a Shared window.
;    *
     ; When the remote user receives the issued #DesktopInput the
     ; event #WM_TEAMTALK_USER_DESKTOPINPUT is posted To the client
     ; instance sharing the desktop window And
     ; TT_GetUserDesktopInput() can be used To retrieve the
     ; transmitted #DesktopInput structs.
;    *
     ; Requires TeamTalk v. 4.6+ client And server.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID who owns the shared desktop window
     ; And should receive desktop input.
     ; @param lpDesktopInputs An Array of #DesktopInput structs which
     ; should be transmitted To the user. Internally in the client
     ; instance each user ID has an internal queue which can contain a
     ; maximum of 100 #DesktopInput structs.
     ; @param nDesktopInputCount Must be less Or equal To #TT_DESKTOPINPUT_MAX.
     ; @return FALSE If user doesn't exist or if desktop input queue is full or
     ; If @c nUserID doesn't subscribe to desktop input. */
    TT_SendDesktopInput(*lpTTInstance,
                                             nUserID.l,
Array *lpDesktopInputs.DesktopInput(#TT_DESKTOPINPUT_MAX),
                                             nDesktopInputCount.l)

    ;*
     ; @brief Get a user's desktop window (bitmap image).
;    *
     ; A user's desktop window can be extracted when the 
     ; #WM_TEAMTALK_USER_DESKTOPWINDOW is received.
;    *
     ; A desktop window is simply a bitmap image. This method is used For
     ; copying the user's bitmap image to a pre-allocated buffer.
;    *
     ; To know the properties of the bitmap call this method With @c
     ; lpBitmap set To NULL And extract the properties in @c
     ; lpDesktopWindow.  The size of the buffer To allocate will be @c
     ; nBytesPerLine multiplied by @c nHeight in the #DesktopWindow.
;    *
     ; For #BMP_RGB8_PALETTE bitmaps check out TT_Palette_GetColorTable().
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The user's ID.
     ; @param lpBitmap Pointer To a pre-allocated buffer where the bitmap
     ; Data will be copied To. Pass NULL To query the byte size of the 
     ; bitmap, so it can be written To @c lpnBitmapSize And @c 
     ; lpDesktopWindow.
     ; @param lpnBitmapSize Size of the allocated bitmap buffer @c
     ; lpBitmap. If @c lpBitmap is NULL the size of the bitmap will be
     ; written To this parameter.
     ; @param lpDesktopWindow The properties of the Shared desktop window.
     ; Pass NULL To @c lpBitmap To query the properties of the desktop 
     ; window.
     ; @return FALSE If there's no active desktop window for this user.
     ; @see TT_SendDesktopWindow() */
    TT_GetUserDesktopWindow(*lpTTInstance, 
                                                 nUserID.l, 
                                                 *lpBitmap, 
                                                 lpnBitmapSize.l,
                                                 *lpDesktopWindow.DesktopWindow)

    ;*
     ; @brief Get the mouse cursor position of a user.
;    *
     ; The mouse cursor position will be available when the
     ; #WM_TEAMTALK_USER_DESKTOPCURSOR is received And there's an
     ; active desktop session.
;    *
     ; A mouse cursor position is transmitted using 
     ; TT_SendDesktopCursorPosition().
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nSrcUserID The owner of the cursor.
     ; @param nDestUserID The owner of the desktop session where the cursor
     ; is pointing To.
     ; @param lpnPosX Output parameter For X coordinate.
     ; @param lpnPosY Output parameter For Y coordinate.
     ; @return FALSE If no coordinates were written To @c lpnPosX And 
     ; @c lpnPosY. */
    TT_GetUserDesktopCursor(*lpTTInstance, 
                                                 nSrcUserID.l,
                                                 nDestUserID.l,
                                                 lpnPosX.l,
                                                 lpnPosY.l)

    ;*
     ; @brief Get desktop (mouse Or keyboard) input received from a user.
;    *
     ; Desktop input is used in combination With a Shared desktop
     ; window, see @ref desktopshare.
;    *
     ; If the local client instance is subscribing To desktop input
     ; (i.e. #SUBSCRIBE_DESKTOPINPUT) then a remote user can send
     ; desktop input To the local client instance. Once the client
     ; instance receives desktop input it posts the message
     ; #WM_TEAMTALK_USER_DESKTOPINPUT And TT_GetUserDesktopInput() can
     ; be used To obtain the #DesktopInput structs send by the remote
     ; user. See @ref rxdesktopinput For more information on receiving
     ; desktop input.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nSrcUserID The user's ID who sent desktop input, see
     ; #WM_TEAMTALK_USER_DESKTOPINPUT.
     ; @param lpDesktopInputs A pre-allocated Array which will receive
     ; the #DesktopInput stucts.
     ; @param lpnDesktopInputCount The number of #DesktopInput structs
     ; written To @c lpDesktopInputs.
     ; @return FALSE If no desktop input could be retrieved.
     ; @see TT_SendDesktopInput()
     ; @see TT_DesktopInput_KeyTranslate()  */
    TT_GetUserDesktopInput(*lpTTInstance, 
                                                nSrcUserID.l,
                                                Array *lpDesktopInputs.DesktopInput(#TT_DESKTOPINPUT_MAX),
                                                lpnDesktopInputCount.l)
    ;* @} */

    ;* @addtogroup connectivity
     ; @{ */

    ;*
     ; @brief Connect To a server. 
     ; 
     ; This is a non-blocking call (but may block due To DNS lookup)
     ; so the user application must wait For the event
     ; #WM_TEAMTALK_CON_SUCCESS To be posted once the connection has
     ; been established Or #WM_TEAMTALK_CON_FAILED If connection could
     ; Not be established. If the connection could Not be establish
     ; ensure To call #TT_Disconnect To close open connections in the
     ; client instance before trying again.
;    *
     ; Once connected call #TT_DoLogin To log on To the server.
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szHostAddress The IP-address Or hostname of the server.
     ; @param nTcpPort The host port of the server (TCP).
     ; @param nUdpPort The audio/video port of the server (UDP).
     ; @param nLocalTcpPort The local TCP port which should be used. 
     ; Setting it To 0 makes OS Select a port number (recommended).
     ; @param nLocalUdpPort The local UDP port which should be used. 
     ; Setting it To 0 makes OS Select a port number (recommended).
     ; @see WM_TEAMTALK_CON_SUCCESS
     ; @see WM_TEAMTALK_CON_FAILED
     ; @see TT_DoLogin */
    TT_Connect(*lpTTInstance,
                                    szHostAddress.s, 
                                    nTcpPort.l, 
                                    nUdpPort.l, 
                                    nLocalTcpPort.l, 
                                    nLocalUdpPort.l)

    ;*
     ; @brief Bind To specific IP-address priot To connecting To server.
;    *
     ; Same As TT_Connect() except that this also allows which IP-address
     ; To bind To on the local Interface.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szHostAddress The IP-address Or hostname of the server.
     ; @param nTcpPort The host port of the server (TCP).
     ; @param nUdpPort The audio/video port of the server (UDP).
     ; @param szBindIPAddr The IP-address To bind To on the local Interface
     ; in dotted decimal format, e.g. 192.168.1.10.
     ; @param nLocalTcpPort The local TCP port which should be used. 
     ; Setting it To 0 makes OS Select a port number (recommended).
     ; @param nLocalUdpPort The local UDP port which should be used. 
     ; Setting it To 0 makes OS Select a port number (recommended).
     ; @see TT_Connect */
    TT_ConnectEx(*lpTTInstance,
                                      szHostAddress.s,
                                      nTcpPort.l,
                                      nUdpPort.l,
                                      szBindIPAddr.s,
                                      nLocalTcpPort.l,
                                      nLocalUdpPort.l)

    ;*
     ; @brief Connect To non-encrypted TeamTalk server.
;    *
     ; This function is only useful in the Professional edition of the
     ; TeamTalk SDK. It enabled the encrypted TeamTalk client To
     ; connect To non-encrypted TeamTalk servers. The Default
     ; behaviour of TT_Connect() And TT_ConnectEx() in the
     ; Professional SDK is To connect To encrypted servers.  */
    TT_ConnectNonEncrypted(*lpTTInstance,
                                                szHostAddress.s,
                                                nTcpPort.l,
                                                nUdpPort.l,
                                                szBindIPAddr.s,
                                                nLocalTcpPort.l,
                                                nLocalUdpPort.l)

    ;*
     ; @brief Disconnect from the server.
     ; 
     ; This will clear the flag #CLIENT_CONNECTED And #CLIENT_CONNECTING.
;    *
     ; Use #TT_CloseTeamTalk To release all resources allocated by the
     ; client instance.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. */
    TT_Disconnect(*lpTTInstance)

    ;*
     ; @brief Query the maximum size of UDP Data packets To the user
     ; Or server.
;    *
     ; The #WM_TEAMTALK_CON_MAX_PAYLOAD_UPDATED event is posted when
     ; the query has finished.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk. 
     ; @param nUserID The ID of the user To query Or 0 For querying 
     ; server. Currently only @c nUserID = 0 is supported. */
    TT_QueryMaxPayload(*lpTTInstance,
                                            nUserID.l)
    
    ;* 
     ; @brief Set how often the client should ping the server on its TCP
     ; And UDP connection.
;    *
     ; Ensure that both the TCP Or the UDP ping interval is less than
     ; the server's user-timeout specified by @a nUserTimeout in
     ; #ServerProperties. UDP keep-alive packets also updates the
     ; ping-time To the server in @a nUdpPingTimeMs of
     ; #ClientStatistics.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nTcpPingIntervalSec Seconds between issuing the ping-command.
     ; Passing 0 will make the client instance use Default settings.
     ; @param nUdpPingIntervalSec Seconds between sending UDP keepalive
     ; packets To the server (And p2p users). Passing 0 will make the 
     ; client instance use Default settings.
     ; @see ServerProperties */
    TT_SetKeepAliveInterval(*lpTTInstance,
                                                 nTcpPingIntervalSec.l,
                                                 nUdpPingIntervalSec.l)

    ;* 
     ; @brief Gets how often the client is sending keep-alive information To the 
     ; server.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param lpnTcpPingIntervalSec The number of seconds between issuing the 
     ; 'ping' command.
     ; @param lpnUdpPingIntervalSec The number of seconds between sending UDP
     ; keepalive packets.
     ; @see TT_SetKeepAliveInterval */
    TT_GetKeepAliveInterval(*lpTTInstance,
                                                 lpnTcpPingIntervalSec.l,
                                                 lpnUdpPingIntervalSec.l)

    ;*
     ; @brief Set server timeout For the client instance.
     ; 
     ; Set the number of seconds the client should allow the server
     ; Not To respond To keepalive requests
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nTimeoutSec Seconds before dropping connection If server hasn't 
     ; replied. Passing 0 will use Default (180 seconds). */
    TT_SetServerTimeout(*lpTTInstance, 
                                             nTimeoutSec.l)

    ;*
     ; @brief Get the server timeout For the client instance.
     ; 
     ; Get the number of seconds the client should allow the server
     ; Not To respond To keepalive requests
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @return The number of seconds. On error -1. */
    TT_GetServerTimeout(*lpTTInstance)

    ;*
     ; @brief Enable/disable peer To peer Data transmission.
     ; 
     ; Peer To peer Data transmission will reduce Data transmission time,
     ; since packets will Not be forwarded through the server. This, however,
     ; increases the bandwidth usage For clients since a separate Data packet
     ; will be sent To each user in a channel, instead of just sending a 
     ; single packet To the server which would then broadcast the packet.
;    *
     ; Note that peer To peer Data transmission is very unreliable And will 
     ; only work With simple NAT-devices. Once a peer To peer connection 
     ; succeeds Or fails the event #WM_TEAMTALK_CON_P2P is posted.
;    *
     ; If the client instance is unable To connect With peer To peer
     ; To a user it will try And forward the Data packet through the
     ; server If #USERRIGHT_FORWARD_AUDIO Or #USERRIGHT_FORWARD_VIDEO are
     ; enabled.
;    *
     ; @see TT_GetServerProperties
     ; @see UserRights */
    TT_EnablePeerToPeer(*lpTTInstance,
                                             mask.l,
                                             bEnable.a)
    ;*
     ; @brief Retrieve client statistics of bandwidth usage And
     ; response times.
;    *
     ; @see ClientStatistics */
     TT_GetStatistics(*lpTTInstance,
                                           *lpStats.ClientStatistics)

    ;* 
     ; @brief Get the number of bytes in a packet With the specified
     ; audio codec. 
;    *
     ; Note that this is only an estimate which doesn't include
     ; headers of underlying protocols.
;    *
     ; @param lpCodec The codec settings To test For packet size
     ; @see AudioCodec */
    TT_GetPacketSize(*lpCodec.AudioCodec)
    ;* @} */

    ;* @addtogroup commands
     ; @{ */

    ;*
     ; @brief Logon To a server.
     ; 
     ; Once connected To a server call this function To logon. If
     ; the login is successful #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN is
     ; posted, otherwise #WM_TEAMTALK_CMD_ERROR. Once logged on it's
     ; Not possible To talk To other users Until the client instance
     ; joins a channel. Call #TT_DoJoinChannel To join a channel.
;    *
     ; Possible errors:
     ; - #CMDERR_INCORRECT_CHANNEL_PASSWORD
     ; - #CMDERR_INVALID_ACCOUNT
     ; - #CMDERR_MAX_SERVER_USERS_EXCEEDED
     ; - #CMDERR_SERVER_BANNED
     ; - #CMDERR_ALREADY_LOGGEDIN
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szNickname The nickname To use.
     ; @param szServerPassword The server's password. Leave empty if user has 
     ; account on the server.
     ; @param szUsername If #USERRIGHT_GUEST_LOGIN is disabled a username And 
     ; password must be specified in order To login. Leave blank If guest 
     ; logins are ok.
     ; @param szPassword The password of the user account on the server. Leave 
     ; blank If no account is needed on the server.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see USERRIGHT_GUEST_LOGIN
     ; @see ServerProperties
     ; @see TT_DoJoinChannel
     ; @see WM_TEAMTALK_CMD_MYSELF_LOGGEDIN
     ; @see WM_TEAMTALK_CMD_ERROR */
    TT_DoLogin(*lpTTInstance,
                                     szNickname.s, 
                                     szServerPassword.s,
                                     szUsername.s,
                                     szPassword.s)

    ;*
     ; @brief Logout of the server.
;    *
     ; If successful the event #WM_TEAMTALK_CMD_MYSELF_LOGGEDOUT
     ; will be posted.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see WM_TEAMTALK_CMD_MYSELF_LOGGEDOUT */
    TT_DoLogout(*lpTTInstance)

    ;*
     ; @brief Create a new channel And join it. This command requires
     ; that the flag #USERRIGHT_CHANNEL_CREATION is set in @a uUserRights
     ; of #ServerProperties.
;    *
     ; This function can also be used To join an existing channel And
     ; in this Case the parameters @a szTopic And @a szOpPassword are
     ; ignored.
;    *
     ; When #TT_DoJoinChannel is used To create channels it works
     ; similar To IRC. If the client instance tres To join a channel
     ; which does Not exist it will be created As a new channel. If
     ; the client instance is the last user To leave a channel the
     ; channel will be removed on the server. Only administrators can
     ; create Static (persistent) channels, namely by using
     ; #TT_DoMakeChannel.
;    *
     ; If the channel is created successfully the event
     ; #WM_TEAMTALK_CMD_CHANNEL_NEW will be sent, followed by
     ; #WM_TEAMTALK_CMD_MYSELF_JOINED.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_INCORRECT_CHANNEL_PASSWORD
     ; - #CMDERR_MAX_CHANNEL_USERS_EXCEEDED
     ; - #CMDERR_ALREADY_IN_CHANNEL
     ; - #CMDERR_AUDIOCODEC_BITRATE_LIMIT_EXCEEDED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpChannel The channel To join Or create If it doesn't already
     ; exist.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoLeaveChannel
     ; @see TT_DoMakeChannel
     ; @see WM_TEAMTALK_CMD_CHANNEL_NEW
     ; @see WM_TEAMTALK_CMD_MYSELF_JOINED */
    TT_DoJoinChannel(*lpTTInstance,
                                           *lpChannel.Channel)

    ;*
     ; @brief Join an existing channel.
     ; 
     ; This command basically calls #TT_DoJoinChannel but omits the
     ; unnecessary parameters For only joining a channel And Not
     ; creating a new one.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_INCORRECT_CHANNEL_PASSWORD
     ; - #CMDERR_MAX_CHANNEL_USERS_EXCEEDED
     ; - #CMDERR_ALREADY_IN_CHANNEL
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel To join.
     ; @param szPassword The password For the channel To join.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoLeaveChannel
     ; @see TT_DoMakeChannel
     ; @see WM_TEAMTALK_CMD_CHANNEL_NEW
     ; @see WM_TEAMTALK_CMD_MYSELF_JOINED */
    TT_DoJoinChannelByID(*lpTTInstance,
                                               nChannelID.l, 
                                               szPassword.s)

    ;*
     ; @brief Leave the current channel.
;    *
     ; Note that #TT_DoLeaveChannel() doesn't take any parameters
     ; since a user can only participate in one channel at the time.
     ; If command is successful the event #WM_TEAMTALK_CMD_MYSELF_LEFT
     ; will be posted.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_NOT_IN_CHANNEL
     ; - #CMDERR_CHANNEL_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoJoinChannel
     ; @see WM_TEAMTALK_CMD_MYSELF_LEFT */
    TT_DoLeaveChannel(*lpTTInstance)

    ;*
     ; @brief Change the client instance's nick name.
;    *
     ; The event #WM_TEAMTALK_CMD_USER_UPDATE will be posted If the
     ; update was successful.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szNewNick is the new nick name To use.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see WM_TEAMTALK_CMD_USER_UPDATE */
    TT_DoChangeNickname(*lpTTInstance, 
                                              szNewNick.s)

    ;*
     ; @brief Change the client instance's currect status
;    *
     ; The event #WM_TEAMTALK_CMD_USER_UPDATE will be posted If the update
     ; was successful.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nStatusMode The value For the status mode.
     ; @param szStatusMessage The user's message associated with the status 
     ; mode.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see WM_TEAMTALK_CMD_USER_UPDATE */
    TT_DoChangeStatus(*lpTTInstance,
                                            nStatusMode.l, 
                                            szStatusMessage.s)

    ;*
     ; @brief Send a text message To either a user Or a channel. 
;    *
     ; Can also be a broadcast message which is received by all users
     ; on the server.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED 
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpTextMessage A preallocated text-message struct.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see USERRIGHT_CLIENT_BROADCAST */
    TT_DoTextMessage(*lpTTInstance,
                                           *lpTextMessage.TextMessage)

    ;*
     ; @brief Make another user operator of a channel. 
     ; 
     ; Requires that the client instance must already be operator of
     ; the channel Or is logged in As an administrator.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The user who should become channel operator. 
     ; @param nChannelID The channel where the user should become operator.
     ; @param bMakeOperator Whether user should be op'ed or deop'ed.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoChannelOpEx */
    TT_DoChannelOp(*lpTTInstance,
                                         nUserID.l,
                                         nChannelID.l,
                                         bMakeOperator.a)

    ;*
     ; @brief Make another user operator of a channel using the 
     ; @a szOpPassword of #Channel.
     ; 
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_USER_NOT_FOUND
     ; - #CMDERR_INCORRECT_OP_PASSWORD
;    *
     ; @note
     ; Requires server version 4.1.0.994 Or later.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The user who should become channel operator. 
     ; @param nChannelID The channel where the user should become operator.
     ; @param szOpPassword The @a szOpPassword of #Channel.
     ; @param bMakeOperator Whether user should be op'ed or deop'ed.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoChannelOp */
    TT_DoChannelOpEx(*lpTTInstance,
                                           nUserID.l,
                                           nChannelID.l,
                                           szOpPassword.s,
                                           bMakeOperator.a)

    ;*
     ; @brief Kick user out of channel. 
;    *
     ; Only a channel operator Or administration can kick users. To
     ; ban a user call #TT_DoBanUser before #TT_DoKickUser.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user To kick. 
     ; @param nChannelID The channel where the user is participating. If
     ; local instance is admin And @a nChannelID is 0, the user will be kicked
     ; off the server. 
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoBanUser */
    TT_DoKickUser(*lpTTInstance,
                                        nUserID.l,
                                        nChannelID.l)

    ;*
     ; @brief Send a file To the specified channel. 
;    *
     ; If user is logged on As an admin the file can be located in any 
     ; channel. If the user is Not an admin the file must be located in 
     ; the same channel As the user is currently participating in.
     ; The file being uploaded
     ; must have a file size which is less than the disk quota of the channel, 
     ; minus the sum of all the files in the channel. The disk quota of a
     ; channel can be obtained in the nDiskQuota of the #Channel struct passed 
     ; To #TT_GetChannel.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_MAX_DISKUSAGE_EXCEEDED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_FILETRANSFER_NOT_FOUND
     ; - #CMDERR_OPENFILE_FAILED
     ; - #CMDERR_FILE_NOT_FOUND
     ; - #CMDERR_FILE_ALREADY_EXISTS
     ; - #CMDERR_FILESHARING_DISABLED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel of where To put the file. Only 
     ; admins can upload in channel other then their own.
     ; @param szLocalFilePath The path of the file To upload, e.g. C:\\myfile.txt.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see Channel
     ; @see TT_GetChannel */
    TT_DoSendFile(*lpTTInstance,
                                        nChannelID.l,
                                        szLocalFilePath.l)

    ;*
     ; @brief Download a file from the specified channel. 
;    *
     ; If user is logged on As an admin the file can be located in any 
     ; channel. If the user is Not an admin the file must be located in 
     ; the same channel As the user is currently participating in.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_FILETRANSFER_NOT_FOUND
     ; - #CMDERR_OPENFILE_FAILED
     ; - #CMDERR_FILE_NOT_FOUND
     ; - #CMDERR_FILESHARING_DISABLED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel of where To get the file. Only 
     ; admins can download in channel other then their own.
     ; @param nFileID The ID of the file which is passed by #WM_TEAMTALK_CMD_FILE_NEW.
     ; @param szLocalFilePath The path of where To store the file, e.g. 
     ; C:\\myfile.txt.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see WM_TEAMTALK_CMD_FILE_NEW
     ; @see TT_GetChannelFiles */
    TT_DoRecvFile(*lpTTInstance,
                                        nChannelID.l,
                                        nFileID.l, 
                                        szLocalFilePath.s)

    ;*
     ; @brief Delete a file from a channel. 
;    *
     ; A user is allowed To delete a file from a channel If either the
     ; user is an admin, operator of the channel Or owner of the
     ; file. To be owner of the file a user must have a #UserAccount
     ; on the server.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED 
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_FILE_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel where the file is located.
     ; @param nFileID The ID of the file To delete. The ID of the file which 
     ; is passed by #WM_TEAMTALK_CMD_FILE_NEW.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see WM_TEAMTALK_CMD_FILE_NEW
     ; @see TT_GetChannelFiles */
    TT_DoDeleteFile(*lpTTInstance,
                                          nChannelID.l,
                                          nFileID.l)

    ;*
     ; @brief Subscribe To user events And/Or Data.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED 
     ; - #CMDERR_SUBSCRIPTIONS_DISABLED
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user this should affect.
     ; @param uSubscriptions Union of #Subscription To subscribe To.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see Subscription */
    TT_DoSubscribe(*lpTTInstance,
                                         nUserID.l, 
                                         uSubscriptions.l)

    ;*
     ; @brief Unsubscribe To user events/Data. This can be used To ignore messages
     ; Or voice Data from a specific user.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED 
     ; - #CMDERR_SUBSCRIPTIONS_DISABLED
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user this should affect.
     ; @param uSubscriptions Union of #Subscription To unsubscribe.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see Subscription */
    TT_DoUnsubscribe(*lpTTInstance,
                                           nUserID.l, 
                                           uSubscriptions.l)

    ;*
     ; @brief Make a Static (persistent) channel.
     ; 
     ; This command only works For admins since it creates a persistent
     ; channel on the server which will be stored in the server's
     ; config file.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_ALREADY_EXISTS
     ; - #CMDERR_CHANNEL_NOT_FOUND If channel's combined path is longer than
     ;   #TT_STRLEN.
     ; - #CMDERR_INCORRECT_CHANNEL_PASSWORD If the password is longer than
     ;   #TT_STRLEN.
     ; - #CMDERR_UNKNOWN_AUDIOCODEC If the server doesn't support the audio
     ;   codec. Introduced in version 4.1.0.1264.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpChannel A Channel-Structure containing information about
     ; the channel being created. The Channel's member @a nChannelID is ignored.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoJoinChannel */
    TT_DoMakeChannel(*lpTTInstance,
                                           *lpChannel.Channel)

    ;*
     ; @brief Update a channel's properties.
;    *
     ; Admin And operators of channel can update a channel's
     ; properties. Note that a channel's #AudioCodec cannot be changed
     ; If there's currently users in the channel.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED 
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_CHANNEL_HAS_USERS
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpChannel A Channel-Structure containing information about
     ; the channel being modified. The channel member's \a nParentID
     ; And \a szName are ignored.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoMakeChannel */
    TT_DoUpdateChannel(*lpTTInstance,
                                             *lpChannel.Channel)

    ;*
     ; @brief Remove a channel from a server. 
;    *
     ; This command only applies To admins.
;    *
     ; If there's any users in the channel they will be kicked and
     ; subchannels will be deleted As well.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.  
     ; @param nChannelID The ID of the channel To remove.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoMakeChannel */
    TT_DoRemoveChannel(*lpTTInstance,
                                             nChannelID.l)

    ;*
     ; @brief Issue command To move a user from one channel To
     ; another.
;    *
     ; This command only applies To admins.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_CHANNEL_NOT_FOUND
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID User To be moved.
     ; @param nChannelID Channel where user should be put into.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoMoveUserByID */
    TT_DoMoveUser(*lpTTInstance,
                                        nUserID.l, 
                                        nChannelID.l)

    ;*
     ; @brief Update server properties.
;    *
     ; This command only applies To admins.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_SERVER_HAS_USERS
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpServerProperties A Structure holding the information To be set 
     ; on the server.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_GetServerProperties */
    TT_DoUpdateServer(*lpTTInstance,
                                            *lpServerProperties.ServerProperties)

    ;*
     ; @brief Issue command To List user accounts on the server.
;    *
     ; User accounts can be used To create different user types like
     ; e.g. administrators.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nIndex Index of first user To display.
     ; @param nCount The number of users To retrieve.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see UserAccount
     ; @see UserType
     ; @see TT_GetUserAccounts */
    TT_DoListUserAccounts(*lpTTInstance,
                                                nIndex.l,
                                                nCount.l)

    ;*
     ; @brief Issue command To create a new user account on the
     ; server.
;    *
     ; Check out section @ref useradmin To see how the server handles
     ; users.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_INVALID_ACCOUNT
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpUserAccount The properties of the user account To create.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoListUserAccounts
     ; @see TT_DoDeleteUserAccount
     ; @see UserAccount
     ; @see UserType */
    TT_DoNewUserAccount(*lpTTInstance,
                                              *lpUserAccount.UserAccount)

    ;*
     ; @brief Issue command To delete a user account on the server.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_ACCOUNT_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szUsername The username of the user account To delete.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoListUserAccounts
     ; @see TT_DoNewUserAccount
     ; @see UserAccount
     ; @see UserType */
    TT_DoDeleteUserAccount(*lpTTInstance,
                                                 szUsername.s)

    ;*
     ; @brief Issue a ban command on a user. 
;    *
     ; The ban applies To the user's IP-address. Call #TT_DoKickUser
     ; To kick the user off the server. Only admins can ban users.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_USER_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user To ban.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoKickUser
     ; @see TT_DoListBans
     ; @see TT_DoBanIPAddress */
    TT_DoBanUser(*lpTTInstance,
                                       nUserID.l)


    ;*
     ; @brief Issue a ban command on an IP-address user. 
;    *
     ; Same As TT_DoBanUser() except this command applies To IP-addresses
     ; And therefore doesn't require a user to be logged in.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szIpAddress The IP-address To ban.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoKickUser
     ; @see TT_DoListBans */
    TT_DoBanIPAddress(*lpTTInstance,
                                            szIpAddress.s)

    ;*
     ; @brief Unban the user With the specified IP-address.
;    *
     ; Only admins can remove a ban.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_BAN_NOT_FOUND
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szIpAddress The IP-address To unban.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoBanUser
     ; @see TT_DoListBans
     ; @see TT_DoBanIPAddress */
    TT_DoUnBanUser(*lpTTInstance,
                                         szIpAddress.s)

    ;*
     ; @brief Issue a command To List the banned users.
;    *
     ; Only admins can List bans. Once completed call the function
     ; #TT_GetBannedUsers To get the List of users.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nIndex Index of first ban To display.
     ; @param nCount The number of bans To display.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_InitTeamTalk
     ; @see TT_GetBannedUsers */
    TT_DoListBans(*lpTTInstance,
                                        nIndex.l,
                                        nCount.l)

    ;*
     ; @brief Save the server's current state to its settings file (typically 
     ; the server's .xml file).
;    *
     ; Note that the server only saves channels With the flag
     ; #CHANNEL_STATIC.
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error.
     ; @see TT_DoUpdateServer */
    TT_DoSaveConfig(*lpTTInstance)

    ;*
     ; @brief Get the server's current statistics obtained through
     ; TT_GetServerStatistics().
;    *
     ; Possible errors:
     ; - #CMDERR_NOT_LOGGEDIN
     ; - #CMDERR_NOT_AUTHORIZED
     ; - #CMDERR_UNKNOWN_COMMAND
;    *
     ; @note
     ; Requires server version 4.1.0.1089 Or later.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error. */
    TT_DoQueryServerStats(*lpTTInstance)

    ;*
     ; @brief Quit from server. 
;    *
     ; Possible errors:
     ; - none
;    *
     ; This will generate a #WM_TEAMTALK_CON_LOST since the server
     ; will drop the client.
;    *
     ; @return Returns command ID which will be passed in 
     ; #WM_TEAMTALK_CMD_PROCESSING event when the server is processing the 
     ; command. -1 is returned in Case of error. */
    TT_DoQuit(*lpTTInstance)
    ;* @} */

    ;* @addtogroup server
;    *
     ; @brief Get the server's properties.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpProperties A struct To hold the server's properties. */
    TT_GetServerProperties(*lpTTInstance,
                                                *lpProperties.ServerProperties)

    ;*
     ; @brief Get the server's statistics, i.e. bandwidth usage etc.

     ; @see TT_DoQueryServerStatistics
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpStatistics A struct To hold the server's statistics. */
    TT_GetServerStatistics(*lpTTInstance,
                                                *lpStatistics.ServerStatistics)

    ;*
     ; @brief Get the IDs of all the users on the server.
;    *
     ; Extracts the user IDs of all the users on the server. If only users in
     ; a specific channel is needed call TT_GetChannelUsers()
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpUserIDs A preallocated Array which has room For @a lpnHowMany 
     ; user ID elements. Pass NULL To query the number of users in channel.
     ; @param lpnHowMany The number of elements in the Array @a lpUserIDs. If
     ; @a lpUserIDs is NULL @a lpnHowMany will receive the number of users in
     ; the channel.
     ; @see TT_GetChannelUsers
     ; @see TT_GetUser 
     ; @see TT_GetServerChannels*/
    TT_GetServerUsers(*lpTTInstance,
                                           lpUserIDs.l,
                                           lpnHowMany.l)
    ;* @} */

    ;* @addtogroup channels
     ; @{ */

    ;*
     ; @brief Get the root channel's ID
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns the ID of the root channel. If 0 is returned no root 
     ; channel exists.
     ; @see TT_GetMyChannelID
     ; @see TT_GetChannelPath */
    TT_GetRootChannelID(*lpTTInstance)

    ;*
     ; @brief Get the channel which the local client instance is
     ; currently participating in.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns the ID of the current channel. If 0 is returned the 
     ; user is Not participating in a channel. */
    TT_GetMyChannelID(*lpTTInstance)

    ;*
     ; @brief Get the channel With a specific ID.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel To get information about.
     ; @param lpChannel A preallocated struct which will receive the 
     ; channel's properties.
     ; @return FALSE If unable To retrieve channel otherwise TRUE. */
    TT_GetChannel(*lpTTInstance,
                                       nChannelID.l, 
                                       *lpChannel.Channel)

    ;*
     ; @brief Get the channel's path. Channels are separated by '/'.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The channel's ID.
     ; @param szChannelPath Will receive the channel's path.
     ; @return Returns TRUE If channel exists. */
    TT_GetChannelPath(*lpTTInstance,
                                           nChannelID.l, 
                                           szChannelPath.s)

    ;*
     ; @brief Get the channel ID of the supplied path. Channels are
     ; separated by '/'
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szChannelPath Will receive the channel's path.
     ; @return The channel's ID or 0 on error. */
    TT_GetChannelIDFromPath(*lpTTInstance,
                                                  szChannelPath.s)

    ;*
     ; @brief Get the IDs of all users in a channel.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The channel's ID.
     ; @param lpUserIDs A preallocated Array which has room For @a lpnHowMany 
     ; user ID elements. Pass NULL To query the number of users in channel.
     ; @param lpnHowMany The number of elements in the Array @a lpUserIDs. If
     ; @a lpUserIDs is NULL @a lpnHowMany will receive the number of users in
     ; the channel.
     ; @see User 
     ; @see TT_GetChannel */
    TT_GetChannelUsers(*lpTTInstance,
                                            nChannelID.l,
                                            lpUserIDs.l,
                                            lpnHowMany.l)

    ;*
     ; @brief Get the List of the files in a channel which can be
     ; downloaded.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel To extract the files from.
     ; @param lpFileInfos A preallocated struct which will receive 
     ; file information. If @a lpFileInfo is NULL then @a lpnHowMany will
     ; receive the number of files in the channel.
     ; @param lpnHowMany Use For both querying And specifying the number of
     ; files. If @a lpFileInfos is NULL then lpnHowMany will receive the number
     ; of files in the channel. If @a lpFileInfos is Not NULL then
     ; @a lpnHowMany should specify the size of the @a lpFileInfos Array.
     ; @see TT_GetChannelFileInfo */
    TT_GetChannelFiles(*lpTTInstance,
                                            nChannelID, 
                                            *lpFileInfos.FileInfo,
                                            lpnHowMany.l)

    ;*
     ; @brief Get information about a file which can be downloaded.
;    *
     ; Typically this is called after receiving
     ; #WM_TEAMTALK_CMD_FILE_NEW.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nChannelID The ID of the channel To extract the file from.
     ; @param nFileID The ID of the file.
     ; @param lpFileInfo A preallocated struct which will receive 
     ; file information. */
    TT_GetChannelFileInfo(*lpTTInstance,
                                               nChannelID.l, 
                                               nFileID.l, 
                                               *lpFileInfo.FileInfo)
    
    ;*
     ; @brief Check whether user is operator of a channel
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID the ID of the user To check.
     ; @param nChannelID the ID of the channel To check whether user
     ; is operator of. */
    TT_IsChannelOperator(*lpTTInstance,
                                              nUserID.l, 
                                              nChannelID.l)

    ;* 
     ; @brief Get the IDs of all the channels on the server.
;    *
     ; Use TT_GetChannel() To get more information about each of the
     ; channels. 
     ; @see TT_GetServerUsers() */
    TT_GetServerChannels(*lpTTInstance,
                                              lpChannelIDs,
                                              lpnHowMany.l)
    ;* @} */

    ;* @addtogroup users
     ; @{ */

    ;*
     ; @brief Get the local client instance's user ID. 
;    *
     ; This information can be retrieved after the
     ; #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN event.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return Returns the user ID assigned To the current user on the server.
     ; -1 is returned If no ID has been assigned To the user. */
    TT_GetMyUserID(*lpTTInstance)

    ;*
     ; @brief Get the local client instance's #UserAccount.
;    *
     ; This information can be retrieved after
     ; #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN event.
;    *
     ; @note
     ; Requires server version 4.0.1.970 Or later.
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpUserAccount The local client's user account registered on
     ; the server. Note that the @a szPassword field of #UserAccount
     ; will Not be set.
     ; @see TT_DoLogin */
    TT_GetMyUserAccount(*lpTTInstance,
                                             *lpUserAccount.UserAccount)

    ;*
     ; @brief Get the client instance's user type. 
;    *
     ; This information can be retrieved after
     ; #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN event.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return A bitmask of the type of user based on #UserType.
     ; @see TT_GetMyUserAccount
     ; @see TT_DoLogin
     ; @see UserType */
    TT_GetMyUserType(*lpTTInstance)

    ;*
     ; @brief If an account was used in #TT_DoLogin then this value will 
     ; Return the @a nUserData from the #UserAccount.
;    *
     ; This information can be retrieved after
     ; #WM_TEAMTALK_CMD_MYSELF_LOGGEDIN event.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @return If set, @a nUserData from #UserAccount, otherwise 0.
     ; @see TT_GetMyUserAccount */
    TT_GetMyUserData(*lpTTInstance)

    ;*
     ; @brief Get the user With the specified ID.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user To extract.
     ; @param lpUser A preallocated #User struct.
     ; @see TT_GetUserByUsername */
    TT_GetUser(*lpTTInstance,
                                    *lpUser.User)
    
    ;*
     ; @brief Get statistics For Data And packet reception from a user.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user To extract.
     ; @param lpStats A preallocated #UserStatistics struct. */
    TT_GetUserStatistics(*lpTTInstance,
                                              nUserID.l, 
                                              *lpStats.UserStatistics);
    ;*
     ; @brief Get the user With the specified username.
;    *
     ; Remember To take into account that multiple users can log in
     ; With the same account If #USERRIGHT_DOUBLE_LOGIN is specified.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param szUsername The user's username (from #UserAccount).
     ; @param lpUser A preallocated #User struct. */
    TT_GetUserByUsername(*lpTTInstance,
                                              szUsername.s, 
                                              *lpUser.user)
    ;*
     ; @brief Get a text-message sent by a user.
;    *
     ; The client instance uses a cyclic buffer in order Not To drain
     ; resources And can hold a maximum of 65535 text-messages.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nMsgID The ID of the message To extract.
     ; @param bRemoveMsg Clear the text-message To release resources.
     ; @param lpTextMessage Will receive the content of the message extracted. 
     ; Pass NULL If only called To remove the message. */
    TT_GetTextMessage(*lpTTInstance,
                                           nMsgID.l, 
                                           bRemoveMsg.a,
                                           *lpTextMessage.TextMessage)
    ;* @} */

    ;* @addtogroup sounddevices
     ; @{ */

    ;*
     ; @brief Set the volume of a user.
;    *
     ; Note that it's a virtual volume which is being set since the
     ; master volume affects the user volume.
     ; 
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user whose volume will be changed.
     ; @param nVolume Must be between #SOUND_VOLUME_MIN And #SOUND_VOLUME_MAX.
     ; @see TT_SetSoundOutputVolume */
    TT_SetUserVolume(*lpTTInstance,
                                          nUserID.l,
                                          nVolume.l)

    ;*
     ; @brief Get the volume of a user. 
;    *
     ; Note that it's a virtual volume which is being set since the
     ; master volume affects the user volume.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user.
     ; @return A value between #SOUND_VOLUME_MIN And #SOUND_VOLUME_MAX */
    TT_GetUserVolume(*lpTTInstance,
                                           nUserID.l)

    ;*
     ; @brief Use software To gain a user's volume.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user who should have sound gained.
     ; @param nGainLevel The gain level For the user. A value from
     ; #SOUND_GAIN_MIN To #SOUND_GAIN_MAX
     ; @see TT_GetUserGainLevel
     ; @see SOUND_GAIN_DEFAULT */
    TT_SetUserGainLevel(*lpTTInstance,
                                             nUserID.l, 
                                             nGainLevel.l)

    ;*
     ; @brief Get the software gain level For a user.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user whose gain level should be retrieved.
     ; @see TT_SetUserGainLevel
     ; @return The gain level For the user. A value from #SOUND_GAIN_MIN To 
     ; #SOUND_GAIN_MAX */
    TT_GetUserGainLevel(*lpTTInstance,
                                              nUserID.l)

    ;*
     ; @brief Mute a user.
;    *
     ; To stop receiving audio from a user call #TT_DoUnsubscribe With
     ; #SUBSCRIBE_AUDIO.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The user ID of the user To mute (Or unmute).
     ; @param bMute TRUE will mute, FALSE will unmute.
     ; @see TT_SetSoundOutputMute */
    TT_SetUserMute(*lpTTInstance,
                                        nUserID.l,
                                         bMute.a)

    ;*
     ; @brief Set the delay of when a user should be considered To no
     ; longer be talking.
;    *
     ; When a user starts talking the #WM_TEAMTALK_USER_TALKING is
     ; triggered With its parameter set To active. A user will remain
     ; in this active state Until no packets are received from this
     ; user, plus a Delay (due To network interruptions). This delay
     ; is by Default set To 500 msec but can be changed by calling
     ; TT_SetUserStoppedTalkingDelay().
;    *
     ; @see TT_GetUserStoppedTalkingDelay */
    TT_SetUserStoppedTalkingDelay(*lpTTInstance,
                                                       nUserID.l, 
                                                       nDelayMSec.l)

    ;*
     ; @brief Get the delay of when a user should no longer be considered As talking.
;    *
     ; @return The delay in miliseconds. -1 on error.
     ; @see TT_SetUserStoppedTalkingDelay */
    TT_GetUserStoppedTalkingDelay(*lpTTInstance,
                                                        nUserID.l)

    ;*
     ; @brief Set the position of a user.
;    *
     ; This can only be done using DirectSound (#SOUNDSYSTEM_DSOUND)
     ; And With sound duplex mode (#CLIENT_SNDINOUTPUT_DUPLEX)
     ; disabled.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID ID of user.
     ; @param x Distance in meters To user (left/right).
     ; @param y Distance in meters To user (back/forward).
     ; @param z Distance in meters To user (up/down). */
    TT_SetUserPosition(*lpTTInstance,
                                            nUserID.l, 
                                            x.f,
                                            y.f, 
                                            z.f)

    ;*
     ; @brief Get a user's position.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID ID of user.
     ; @param x Distance in meters To user (left/right).
     ; @param y Distance in meters To user (back/forward).
     ; @param z Distance in meters To user (up/down). */
    TT_GetUserPosition(*lpTTInstance,
                                            nUserID.l, 
                                            x.f, 
                                            y.f, 
                                            z.f)

    ;*
     ; @brief Set whether a user should speak in the left, right Or
     ; both speakers. This function only works If #AudioCodec has been
     ; set To use stereo.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID ID of user.
     ; @param bLeftSpeaker TRUE If user should be played in left speaker.
     ; @param bRightSpeaker TRUE If user should be played in right speaker.
     ; @see TT_GetUserStereo */
    TT_SetUserStereo(*lpTTInstance,
                                          nUserID.l, 
                                          bLeftSpeaker.a, 
                                          bRightSpeaker.a)

    ;*
     ; @brief Check what speaker a user is outputting To.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID ID of user.
     ; @param lpbLeftSpeaker TRUE If playing in left speaker.
     ; @param lpbRightSpeaker TRUE If playing in right speaker.
     ; @see TT_SetUserStereo */
    TT_GetUserStereo(*lpTTInstance,
                                          nUserID.l, 
                                          lpbLeftSpeaker.a, 
                                          lpbRightSpeaker.a)
    ;*
     ; @brief Store user's audio to disk.
     ; 
     ; Set the path of where To store audio from a user To disk. To
     ; store in MP3 format instead of .wav format ensure that the LAME
     ; MP3 encoder file lame_enc.dll is placed in the same directory
     ; As the SDKs DLL files. To stop recording set @a szFolderPath
     ; To an empty string And @a uAFF To #AFF_NONE.
;    *
     ; To store audio of users Not in current channel of the client
     ; instance check out the section @ref spying.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the #User which should store audio To
     ; disk.
     ; @param szFolderPath The path on disk To where files should be
     ; stored.  This value will be stored in @a szAudioFolder of
     ; #User.  
     ; @param szFileNameVars The file name used For audio files can
     ; consist of the following variables: \%nickname\%, \%username\%,
     ; \%userid\%, \%counter\% And a specified time based on @c
     ; strftime (google @c 'strftime' For a description of the
     ; format. The Default format used by TeamTalk is:
     ; '\%Y\%m\%d-\%H\%M\%S #\%userid\% \%username\%'. The \%counter\%
     ; variable is a 9 digit integer which is incremented For each
     ; audio file. The file extension is automatically appended based
     ; on the file type (.wav For #AFF_WAVE_FORMAT And .mp3 For
     ; AFF_MP3_*_FORMAT). Pass NULL Or empty string To revert To
     ; Default format.
     ; @param uAFF The #AudioFileFormat To use For storing audio files. Passing
     ; #AFF_NONE will cancel/reset the current recording.
     ; @return FALSE If path is invalid, otherwise TRUE.
     ; @see User
     ; @see WM_TEAMTALK_USER_AUDIOFILE */
    TT_SetUserAudioFolder(*lpTTInstance,
                                               nUserID.l,
                                               szFolderPath.s,
                                               szFileNameVars.s,
                                               uAFF.l)
    ;*
     ; @brief Change the amount of media Data which can be buffered
     ; in the user's playback queue.
     ; 
     ; Increasing the media buffer size is especially important when
     ; the user is currently streaming a media file using
     ; TT_StartStreamingMediaFileToChannel(). Once streaming has finished
     ; it is recommended To reset the media buffer, i.e. setting it
     ; To zero.
;    *
     ; A simple way To notify users that the client instance is streaming
     ; a media file is To change the status of the local client instance
     ; using TT_DoChangeStatus() Or To send a #TextMessage using
     ; TT_DoTextMessage().
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nUserID The ID of the user who should have changed
     ; the size of the media buffer.
     ; @param nMSec The number of miliseconds of audio And video which
     ; should be allowed To be stored in the media buffer. 2000 - 3000 
     ; msec is a good size For a media buffer. Set the media
     ; buffer size To 0 msec To reset the media buffer To its Default value.
;    */
    TT_SetUserMediaBufferSize(*lpTTInstance,
                                                   nUserID.l,
                                                   nMSec.l)

    ;* @brief Extract the raw audio from a user who has been talking.
;    *
     ; To enable access To user's raw audio first call
     ; TT_EnableAudioBlockEvent(). Whenever new audio becomes
     ; available the event #WM_TEAMTALK_USER_AUDIOBLOCK is generated And 
     ; TT_AcquireUserAudioBlock() can be called To extract the audio.
;    *
     ; The #AudioBlock contains Shared memory With the local client
     ; instance therefore always remember To call
     ; TT_ReleaseUserAudioBlock() To release the Shared memory.
;    *
     ; If TT_AcquireUserAudioBlock() is called multiple times without
     ; calling TT_ReleaseUserAudioBlock() then the same #AudioBlock
     ; will be retrieved again.
;    *
     ; @see TT_ReleaseUserAudioBlock()
     ; @see TT_EnableAudioBlockEvent()
     ; @see WM_TEAMTALK_USER_AUDIOBLOCK */
    TT_AcquireUserAudioBlock(*lpTTInstance,
                                                  nUserID.l,
                                                  *lpAudioBlock.AudioBlock)

    ;* 
     ; @brief Release the Shared memory of an #AudioBlock.
;    *
     ; All #AudioBlock-structures extracted through
     ; TT_AcquireUserAudioBlock() must be released again since they
     ; share memory With the local client instance.
;    *
     ; Never access @c lpRawAudio after releasing its
     ; #AudioBlock. This will cause the application To crash With a
     ; memory exception.
;    *
     ; @see TT_AcquireUserAudioBlock()
     ; @see WM_TEAMTALK_USER_AUDIOBLOCK */
    TT_ReleaseUserAudioBlock(*lpTTInstance,
                                                  nUserID.l)

    ;*
     ; @brief Release all audio blocks of the local client instance.
;    *
     ; This function is only For convenience To ensure that no memory
     ; is leaked. Normally TT_ReleaseUserAudioBlock() should be used
     ; To release #AudioBlock-Data.
     ; @see TT_ReleaseUserAudioBlock()
     ; @see WM_TEAMTALK_USER_AUDIOBLOCK */
    TT_ReleaseAllAudioBlocks(*lpTTInstance)
                                                  
    ;* @} */

    ;* @ingroup channels
     ; @brief Get information about an active file transfer.  
;    *
     ; An active file transfer is one which has been posted through the
     ; event #WM_TEAMTALK_FILETRANSFER.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nTransferID The ID of the file transfer To investigate. Transfer
     ; ID is passed by #WM_TEAMTALK_FILETRANSFER.
     ; @param lpFileTransfer A preallocated struct which will receive the file 
     ; transfer information.
     ; @see TT_CancelFileTransfer */
    TT_GetFileTransferInfo(*lpTTInstance,
                                                nTransferID.l, 
                                                *lpFileTransfer.FileTransfer)

    ;* @ingroup channels
     ; @brief Cancel an active file transfer. 
;    *
     ; An active file transfer is one which has been post through the
     ; event #WM_TEAMTALK_FILETRANSFER.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nTransferID The ID of the file transfer To investigate. Transfer 
     ; ID is passed by #WM_TEAMTALK_FILETRANSFER. */
    TT_CancelFileTransfer(*lpTTInstance,
                                               nTransferID.l)


    ;* @ingroup server
     ; @brief Get the List of banned users.
     ; 
     ; After the command #TT_DoListBans has completed, this function
     ; can be called To retrieve the List of banned users. The List of
     ; banned users can only be retrieved once after which the
     ; internal representation of the users is deleted (To save
     ; memory).
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpBannedUsers A preallocated Array To hold banned users Or NULL
     ; To query how many banned users are listed.
     ; @param lpnHowMany This is both an input And an output
     ; parameter. If @a lpBannedUsers is NULL lpnHowMany will receive
     ; the number of banned users. If @a lpBannedUsers is Not NULL @a
     ; lpnHowMany must contain how many banned users which will fit in
     ; the @a lpBannedUsers Array. Upon returning @a lpnHowMany will
     ; contain how many were actually written To the Array.
     ; @see TT_DoBanUser  */
    TT_GetBannedUsers(*lpTTInstance,
                                           *lpBannedUsers.BannedUser, 
                                           lpnHowMany.l)

    ;* @ingroup server
     ; @brief Get the List of user accounts.
     ; 
     ; After the command #TT_DoListUserAccounts has competed, this
     ; function can be called To retrieve the List of user accounts on
     ; the server. The List of user accounts can only be retrieved
     ; once after which the internal representation of the users is
     ; deleted (To save memory).
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param lpUserAccounts A preallocated Array To hold user accounts Or NULL
     ; To query how many user accounts are available For retrieval.
     ; @param lpnHowMany This is both an input And an output
     ; parameter. If @a lpUserAccounts is NULL lpnHowMany will receive
     ; the number of user accounts. If @a lpUserAccounts is Not NULL
     ; @a lpnHowMany must contain how many user accounts which will
     ; fit in the @a lpUserAccounts Array. Upon returning lpnHowMany
     ; will contain how many were actually written To the Array.
     ; @see TT_DoListUserAccounts
     ; @see UserAccount */
    TT_GetUserAccounts(*lpTTInstance,
                                            *lpUserAccounts.UserAccount, 
                                            lpnHowMany.l)

    ;* @ingroup errorhandling
     ; @brief Get textual discription of an error message.
     ; 
     ; Get a description of an error code posted by either
     ; #WM_TEAMTALK_CMD_ERROR Or #WM_TEAMTALK_INTERNAL_ERROR.
;    *
     ; @param nError The number of the error.
     ; @param szErrorMsg A text description of the error.
     ; @see WM_TEAMTALK_CMD_ERROR
     ; @see WM_TEAMTALK_INTERNAL_ERROR */
    TT_GetErrorMessage(nError.l, 
                                            szErrorMsg.s)


    ;* @addtogroup desktopshare
     ; @{ */

    ;*
     ; @brief Translate To And from TeamTalk's intermediate key-codes (TTKEYCODE).
     ; @see #WM_TEAMTALK_USER_DESKTOPINPUT */
    Enumeration TTKeyTranslate
            ;* @brief Perform no translation. */
        #TTKEY_NO_TRANSLATE                  = 0
        ;* @brief Translate from Windows scan-code to TTKEYCODE. The
         ; Windows scan-code can be retrieved in Windows' @c
         ; WM_KEYDOWN And @c WM_KEYUP event. */
        #TTKEY_WINKEYCODE_TO_TTKEYCODE       = 1
        ;* @brief Translate from TTKEYCODE to Windows scan-code. */
        #TTKEY_TTKEYCODE_TO_WINKEYCODE       = 2
        ;* @brief Translate from Mac OS X Carbon @c kVK_* key-code to
         ; TTKEYCODE. The Mac OS X key-codes are defined in Carbon's
         ; API. */
        #TTKEY_MACKEYCODE_TO_TTKEYCODE       = 3
        ;* @brief Translate from TTKEYCODE to Mac OS X Carbon @c
         ; kVK_* key-code. */
        #TTKEY_TTKEYCODE_TO_MACKEYCODE       = 4
    EndEnumeration

    ;*
     ; @brief Translate platform key-code To And from TeamTalk's
     ; intermediate format.
;    *
     ; Section @ref keytranslate has a table which shows how the keys on a US
     ; 104-keyboard are translated To TeamTalk's intermediate format.
;    *
     ; Section @ref transdesktopinput explains how To transmit key-codes.
;    *
     ; @param nTranslate The key-code format To translate To And from.
     ; @param lpDesktopInputs An Array of #DesktopInput structs To translate.
     ; @param lpTranslatedDesktopInputs A pre-allocated Array of #DesktopInput
     ; struct To hold the translated desktop input.
     ; @param nDesktopInputCount The number of elements To translate in @c
     ; lpDesktopInputs.
     ; @return The number of translated #DesktopInput stucts. If value
     ; is different from @c nDesktopInputCount then some @c uKeyCode
     ; values could Not be translated And have been assigned the value
     ; TT_DESKTOPINPUT_KEYCODE_IGNORE.
     ; @see TT_SendDesktopInput()
     ; @see TT_DesktopInput_Execute() */
    TT_DesktopInput_KeyTranslate(nTranslate.l,
                                                       *lpDesktopInputs.DesktopInput,
                                                       *lpTranslatedDesktopInputs.DesktopInput,
                                                       nDesktopInputCount.l)

    ;*
     ; @brief Execute desktop (mouse Or keyboard) input.
;    *
     ; When executed either a key-press, key-release Or mouse move
     ; will take place on the computer running the client
     ; instance. Remember To calculate the offsets For the mouse
     ; cursor prior To this call. The mouse position will be relative
     ; To the screen resolution.
;    *
     ; The content of the #DesktopInput struct must been translated To
     ; the platform's key-code format prior to this
     ; call. I.e. uKeyCode must be a either a Windows scan-code, Mac
     ; OS X Carbon key-code Or one of the mouse buttons:
     ; #TT_DESKTOPINPUT_KEYCODE_LMOUSEBTN,
     ; #TT_DESKTOPINPUT_KEYCODE_RMOUSEBTN,
     ; #TT_DESKTOPINPUT_KEYCODE_MMOUSEBTN.
;    *
     ; @param lpDesktopInputs The mouse Or keyboard inputs.
     ; @param nDesktopInputCount The number of elements in @c lpDesktopInputs.
     ; @see TT_DesktopInput_KeyTranslate() */
    TT_DesktopInput_Execute(*lpDesktopInputs.DesktopInput,
                                                 nDesktopInputCount.l)

    ;* @} */

CompilerIf #PB_Compiler_OS=#PB_OS_Windows
    
    ;* @addtogroup hotkey
     ; @{ */

    ;*
     ; @brief Register a Global hotkey. 
;    *
     ; When the hotkey becomes active Or inactive it will send
     ; #WM_TEAMTALK_HOTKEY To the HWND passed To #TT_InitTeamTalk.
;    *
     ; A hotkey can e.g. be used As a push-To-talk key
     ; combination. When the hotkey becomes active call
     ; #TT_EnableTransmission.
;    *
     ; Note that having a hotkey enabled makes the Visual Studio
     ; debugger really slow To respond, so when debugging it's best
     ; Not To have hotkeys enabled.
;    *
     ; @param lpTTInstance Pointer To client instance created by 
     ; #TT_InitTeamTalk.
     ; @param nHotKeyID The ID of the hotkey To register. It will be
     ; passed As the WPARAM when the hotkey becomes either active Or inactive.
     ; @param lpnVKCodes An Array of virtual key codes which constitute the
     ; hotkey. This document outlines the virtual key codes:
     ; http://msdn.microsoft.com/en-us/library/ms645540(VS.85).aspx
     ; A hotkey consisting of Left Control+A would have the Array consist of 
     ; [162, 65].
     ; @param nVKCodeCount The number of virtual key codes in the Array
     ; (in other words the size of the @a lpnVKCodes Array).
     ; @see TT_InitTeamTalk
     ; @see TT_HotKey_Unregister
     ; @see TT_HotKey_InstallTestHook */
    TT_HotKey_Register(*lpTTInstance,
                                            nHotKeyID.l, 
                                            lpnVKCodes.l,
                                            nVKCodeCount.l)

    ;*
     ; @brief Unregister a registered hotkey.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nHotKeyID is the ID of the hotkey To unregister.
     ; @see TT_HotKey_Register */
    TT_HotKey_Unregister(*lpTTInstance,
                                              nHotKeyID.l)

    ;*
     ; @brief Check whether hotkey is active.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nHotKeyID is the ID of the registered hotkey. 
     ; @return 1 If active, 0 If inactive, -1 If hotkey-ID is invalid */
    TT_HotKey_IsActive(*lpTTInstance,
                                             nHotKeyID.l)

    ;*
     ; @brief Install a test hook so the HWND will be messaged
     ; whenever a key Or mouse button is pressed.
;    *
     ; Capture the event #WM_TEAMTALK_HOTKEY_TEST.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param hWnd is the handle of the window which will be
     ; notified.
     ; @see TT_HotKey_RemoveTestHook
     ; @see WM_TEAMTALK_HOTKEY_TEST */
    TT_HotKey_InstallTestHook(*lpTTInstance,
                                                   hWnd.l)

    ;*
     ; @brief Remove the test hook again so the @a hWnd in
     ; #TT_HotKey_InstallTestHook will no longer be notified.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @see TT_HotKey_InstallTestHook */
    TT_HotKey_RemoveTestHook(*lpTTInstance)

    ;*
     ; @brief Get a string description of the virtual-key code.
;    *
     ; @param lpTTInstance Pointer To client instance created by
     ; #TT_InitTeamTalk.
     ; @param nVKCode The virtual key code passed in #WM_TEAMTALK_HOTKEY_TEST.
     ; @param szKeyName Will receive key description in local language.
     ; @see TT_HotKey_Register */
    TT_HotKey_GetKeyString(*lpTTInstance,
                                                nVKCode.l,
                                                szKeyName.s)
    ;* @} */
CompilerEndIf

    ; List of structures used internally by TeamTalk. */
    Enumeration TTStructType
           #__AUDIOCODEC
        #__BANNEDUSER
        #__CAPTUREFORMAT
        #__CELTCODEC
        #__CHANNEL
        #__CLIENTSTATISTICS
        #__FILEINFO
        #__FILETRANSFER
        #__SERVERPROPERTIES
        #__SERVERSTATISTICS
        #__SOUNDDEVICE
        #__SPEEXCODEC
        #__TEXTMESSAGE
        #__THEORACODEC
        #__TTMESSAGE
        #__USER
        #__USERACCOUNT
        #__USERSTATISTICS
        #__VIDEOCAPTUREDEVICE
        #__VIDEOCODEC
        #__AUDIOCONFIG
        #__CELTVBRCODEC
        #__SPEEXVBRCODEC
        #__VIDEOFRAME
        #__AUDIOBLOCK
        #__AUDIOFORMAT
        #__MEDIAFILEINFO
        #__DESKTOPINPUT
    EndEnumeration

    ; Get the 'sizeof' of a structure used by TeamTalk. Useful to ensuring 
     ; binary compatibility when integrating With other programming 
     ; languages. */
    TT_DBG_SIZEOF(nType.l)
    ; Get last #ClientEvent WM_TEAMTALK_DUMMY_LAST. */
    TT_DBG_EVENT_LAST()


CompilerIf #PB_Compiler_OS=#PB_OS_Windows ; Exclude mixer and firewall functions from
                    ; non-Windows platforms */

    ;* @addtogroup mixer
     ; @{ */

    ;*
     ; @brief The Windows mixer controls which can be queried by the
     ; TT_Mixer_* functions.
;    *
     ; Wave-In devices which are Not in the enum-Structure can be
     ; accessed by #TT_Mixer_GetWaveInControlCount which allows the user To
     ; query selection based on an index.
;    *
     ; Note that Windows Vista has deprecated mixer controls.
;    *
     ; @see TT_Mixer_SetWaveOutMute
     ; @see TT_Mixer_SetWaveOutVolume
     ; @see TT_Mixer_SetWaveInSelected
     ; @see TT_Mixer_SetWaveInVolume
     ; @see TT_Mixer_GetWaveInControlName
     ; @see TT_Mixer_SetWaveInControlSelected */
    Enumeration MixerControl
            #WAVEOUT_MASTER
        #WAVEOUT_WAVE
        #WAVEOUT_MICROPHONE

        #WAVEIN_MICROPHONE
        #WAVEIN_LINEIN
        #WAVEIN_WAVEOUT
    EndEnumeration

    ;*
     ; @brief Get the number of Windows Mixers available.
;    *
     ; The index from 0 To #TT_Mixer_GetMixerCount()-1 should be passed To the
     ; TT_Mixer_* functions.
     ; @see TT_Mixer_GetMixerName */
    TT_Mixer_GetMixerCount()

    ;*
     ; @brief Get the name of a Windows Mixer based on its name.
;    *
     ; @param nMixerIndex The index of the mixer. Ranging from 0 To 
     ; #TT_Mixer_GetMixerCount()-1.
     ; @param szMixerName The output string receiving the name of the device. */
    TT_Mixer_GetMixerName(nMixerIndex.l,
                                               szMixerName.s)

    ;*
     ; @brief Get the name of the mixer associated With a wave-in device.
     ; 
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param szMixerName The output string receiving the name of the device. 
     ; @see TT_GetSoundInputDevices */
    TT_Mixer_GetWaveInName(nWaveDeviceID.l,
                                                szMixerName.s)

    ;*
     ; @brief Get the name of the mixer associated With a wave-out device.
     ; 
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param szMixerName The output string receiving the name of the device. 
     ; @see TT_GetSoundOutputDevices */
    TT_Mixer_GetWaveOutName(nWaveDeviceID.l,
                                                 szMixerName.s)

    ;*
     ; @brief Mute Or unmute a Windows Mixer Wave-Out device from the
     ; 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @param bMute True If device should be muted, False If it should be
     ; unmuted.
     ; @see TT_Mixer_GetWaveOutMute */
    TT_Mixer_SetWaveOutMute(nWaveDeviceID.l, 
                                                 nControl.l, 
                                                 bMute.a)

    ;*
     ; @brief Get the mute state of a Windows Mixer Wave-Out device
     ; from the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @return TRUE If mute, FALSE If unmuted, -1 on error.
     ; @see TT_Mixer_SetWaveOutMute */
    TT_Mixer_GetWaveOutMute(nWaveDeviceID.l, 
                                                  nControl.l)

    ;*
     ; @brief Set the volume of a Windows Mixer Wave-Out device from
     ; the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @param nVolume A value ranging from 0 To 65535. */
    TT_Mixer_SetWaveOutVolume(nWaveDeviceID.l, 
                                                   nControl.l, 
                                                   nVolume.l)

    ;*
     ; @brief Get the volume of a Windows Mixer Wave-Out device from
     ; the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @return A value ranging from 0 To 65535, Or -1 on error. */
    TT_Mixer_GetWaveOutVolume(nWaveDeviceID.l, 
                                                    nControl.l);

    ;*
     ; @brief Set the selected state of a Windows Mixer Wave-In
     ; device from the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control. */
    TT_Mixer_SetWaveInSelected(nWaveDeviceID.l, 
                                                    nControl.l)

    ;*
     ; @brief Get the selected state of a Windows Mixer Wave-In device
     ; from the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @return TRUE If mute, FALSE If unmuted, -1 on error. */
    TT_Mixer_GetWaveInSelected(nWaveDeviceID.l, 
                                                     nControl.l)

    ;*
     ; @brief Set the volume of a Windows Mixer Wave-In device from
     ; the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @param nVolume A value ranging from 0 To 65535. */
    TT_Mixer_SetWaveInVolume(nWaveDeviceID.l, 
                                                  nControl.l, 
                                                  nVolume.l)

    ;*
     ; @brief Get the volume of a Windows Mixer Wave-In device from
     ; the 'enum' of devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControl A mixer control.
     ; @return A value ranging from 0 To 65535, Or -1 on error. */
    TT_Mixer_GetWaveInVolume(nWaveDeviceID.l, 
                                                   nControl.l)

    ;*
     ; @brief Enable And disable microphone boost.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param bEnable TRUE To enable, FALSE To disable. */
    TT_Mixer_SetWaveInBoost(nWaveDeviceID.l, 
                                                 bEnable.a)
    ;*
     ; @brief See If microphone boost is enabled.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @return TRUE If boost is enabled, FALSE If disabled, -1 on error. */
    TT_Mixer_GetWaveInBoost(nWaveDeviceID.l)

    ;*
     ; @brief Mute/unmute microphone input.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param bEnable TRUE To enable, FALSE To disable. */
    TT_Mixer_SetWaveInMute(nWaveDeviceID.l, 
                                                bEnable.a)

    ;*
     ; @brief See If microphone is muted.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @return TRUE If mute is enabled, FALSE If disabled, -1 on error. */
    TT_Mixer_GetWaveInMute(nWaveDeviceID.l)

    ;*
     ; @brief Get the number of Windows Mixer Wave-In devices.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @return Number of controls, Or -1 on error.
     ; @see TT_Mixer_GetWaveInControlName
     ; @see TT_Mixer_SetWaveInControlSelected
     ; @see TT_Mixer_GetWaveInControlSelected */
    TT_Mixer_GetWaveInControlCount(nWaveDeviceID.l)

    ;*
     ; @brief Get the name of the Wave-In device With the specified
     ; index.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControlIndex The index of the control. Randing from 0 To 
     ; #TT_Mixer_GetWaveInControlCount()-1.
     ; @param szDeviceName The output string of the name of the device.
     ; @see TT_Mixer_GetWaveInControlCount */
    TT_Mixer_GetWaveInControlName(nWaveDeviceID.l, 
                                                       nControlIndex.l, 
                                                       szDeviceName.s)

    ;*
     ; @brief Set the selected state of a Wave-In device in the
     ; Windows Mixer.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControlIndex The index of the device. Randing from 0 To 
     ; #TT_Mixer_GetWaveInControlCount()-1.
     ; @see TT_Mixer_GetWaveInControlCount */
    TT_Mixer_SetWaveInControlSelected(nWaveDeviceID.l, 
                                                           nControlIndex.l)

    ;*
     ; @brief Get the selected state of a Wave-In device in the
     ; Windows Mixer.
;    *
     ; @param nWaveDeviceID The @a nWaveDeviceID from the #SoundDevice
     ; struct.
     ; @param nControlIndex The index of the device. Randing from 0 To  
     ; #TT_Mixer_GetWaveInControlCount()-1.
     ; @return TRUE If selected, FALSE If unselected, -1 on error.
     ; @see TT_Mixer_GetWaveInControlCount */
    TT_Mixer_GetWaveInControlSelected(nWaveDeviceID.l, 
                                                           nControlIndex.l)
    ;* @} */

    ;* @addtogroup firewall
     ; @{ */

    ;*
     ; @brief Check If the Windows Firewall is currently enabled.
;    *
     ; This function does Not invoke UAC on Windows Vista/7.
     ; @see TT_Firewall_Enable */
    TT_Firewall_IsEnabled()
    
    ;*
     ; @brief Enable/disable the Windows Firewall.
;    *
     ; The Windows Firewall was introduced in Windows XP SP2.
;    *
     ; On Windows XP (SP2+) the user calling this function is assumed
     ; To have administrator rights. On Windows Vista/7 UAC is invoked
     ; To ask the user For administrator rights.
     ; @see TT_Firewall_IsEnabled */
    TT_Firewall_Enable(bEnable.a)

    ;*
     ; @brief Check If an executable is already in the Windows
     ; Firewall exception List.
;    *
     ; This function does Not invoke UAC on Windows Vista/7.
     ; @see TT_Firewall_AddAppException */
    TT_Firewall_AppExceptionExists(szExecutable.s)

    ;*
     ; @brief Add an application To the Windows Firewall exception
     ; List.
;    *
     ; On Windows XP (SP2+) the user calling this function is assumed
     ; To have administrator rights. On Windows Vista/7 UAC is invoked
     ; To ask the user For administrator rights.
     ; @see TT_Firewall_AppExceptionExists
     ; @see TT_Firewall_RemoveAppException */
    TT_Firewall_AddAppException(szName.s, 
                                                     szExecutable.s)

    ;*
     ; @brief Remove an application from the Windows Firewall exception
     ; List.
;    *
     ; On Windows XP (SP2+) the user calling this function is assumed
     ; To have administrator rights. On Windows Vista/7 UAC is invoked
     ; To ask the user For administrator rights.
     ; @see TT_Firewall_AppExceptionExists
     ; @see TT_Firewall_AddAppException */
    TT_Firewall_RemoveAppException(szExecutable.s)
    ;* @} */
CompilerEndIf
EndImport
; IDE Options = PureBasic 5.22 LTS (Windows - x64)
; CursorPosition = 6836
; FirstLine = 6834
; EnableXP
; DisableDebugger