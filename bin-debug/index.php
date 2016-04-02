<?php
require_once 'facebook.php';
require_once 'appLoggingFunctions.php';

	$perm='email,user_photos';
	$config_file="invig_config.env";
	$fp_config=null;
	$Log = new AppLoggingFunctions();
	if(!file_exists($config_file)){
		$Log->lwrite("No Config File configured");
	  	die("No Config File configured");
	}
	else{
	  	$fp_config=fopen($config_file,"r");
	}
	$configParam = array();
	while(!feof($fp_config))
	{
		$buffer = fgets($fp_config);
		list($name,$value) = split('=',trim($buffer));
		$configParam[$name] = $value;
	}
	fclose ($fp_config);
	$ipAddress = $_SERVER['REMOTE_ADDR'];
	$fbTime = explode (' ', microtime());
	$Log->lwrite($ipAddress.": FACEBOOK ENTRY TIME SECS: ".$fbTime[1]);
	if(isset($_SERVER['HTTPS'])){
		$protocol = "https";
	}
	else{
		$protocol = "http";
	}
	$Log->lwrite("protocol=".$protocol);
	$pathDir =  getcwd();
	$part = explode('/', $pathDir);
	$currentDir=$part[sizeof($part)-1];
	# Creating the facebook object
	$facebook = new Facebook(array(
		'appId'  => $configParam['appId'],
	   	'secret' => $configParam['secret']
	));
	$appId=$configParam['appId'];
	$redirectUri='https://apps.facebook.com/invig-test';
	$facebook->setRedirectUri($redirectUri);
	$fb_id = $facebook->getUser();
	// We may or may not have this data based on whether the user is logged in.
	//
	// If we have a $user id here, it means we know the user is logged into
	// Facebook, but we don't know if the access token is valid. An access
	// token is invalid if the user logged out of Facebook.

	if ($fb_id) {
	  try {
	    // Proceed knowing you have a logged in user who's authenticated.
	    $user_profile = $facebook->api('/me');
	  } catch (FacebookApiException $e) {
	    error_log($e);
	    $fb_id = null;
	  }
	}
	if ($fb_id==null) {
	    $loginUrl = $facebook->getLoginUrl(array(
	    			'redirect_uri' => $redirectUri,
	    			'scope' => $perm
					));
		$Log->lwrite("NO ACTIVE SESSION");
	    $Log->lwrite($loginUrl);
	    header('P3P: CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');
		echo "<script type='text/javascript'>top.location.href = '$loginUrl';</script>";
	}
	else{
	  	$Log->lwrite("ACTIVE SESSION");
	  	$session=$facebook->getSession();
		$fbTime = explode (' ', microtime());
    	$Log->lwrite($ipAddress.": FACEBOOK INIT TIME SECS: ".$fbTime[1]);
		$permissions = $facebook->api("/me/permissions");
		$publish_permission = "N";
		if (array_key_exists('publish_stream', $permissions['data'][0])) {
		    $publish_permission = "Y";
		}
    	$InvigUrl="PixInvig.swf"."?fbId=".$fb_id."&ver_num=11"."&protocol=".$protocol."&dir=".$currentDir
	    	."&appId=".$appId."&publish=".$publish_permission;
   		$Log->lwrite("InvigUrl: ".$InvigUrl);

		$dsn = "mysql:dbname=".$configParam['database'].";host=".$configParam['server'];
		$user = $configParam['user_name'];
		$password = $configParam['password'];
		$dbh=null;
		try {
		    $dbh = new PDO($dsn, $user, $password);
		} catch (PDOException $e) {
		    $Log->lwrite('Connection failed: ' . $e->getMessage());
		    $dbh=null;
		}
		$mongoCollection=null;
		$mongoDB = null;
		$userCollection = null;
		try {
			$className="Mongo";
			if(class_exists($className)) {
				$mongoCollection = new Mongo('localhost:27017');
				$mongoDB = $mongoCollection->selectDB($configParam['mongodb']);
				$userCollection = $mongoDB->selectCollection($configParam['collection']);
			}
			else{
		    	$Log->lwrite('Mongo Class does not exist');
			}
		}
	 	catch (MongoConnectionException $e) {
		    $Log->lwrite('Mongo Connection failed: ' . $e->getMessage());
		}
		catch (MongoException $e) {
		    $Log->lwrite('Mongo Error: ' . $e->getMessage());
		}
		catch (Exception $ex){
		    $Log->lwrite('Mongo Error: ' . $ex->getMessage());
		}
		if($dbh!=null){
			$sth = $dbh->prepare("SELECT user_id, fb_id FROM user WHERE fb_id= :id");
			$sth->bindParam(':id', $fb_id, PDO::PARAM_INT);
			$sth->execute();
			$userResult = $sth->fetchAll(PDO::FETCH_ASSOC);
			$userCount = count($userResult);
			$userId=null;
			if(!$userResult || ($userCount== 0)){//new user, add him to the database
				$sth = $dbh->prepare('INSERT INTO user(fb_id ,fb_gender,fb_user_name,fb_dob,fb_email,
					fb_location,fb_timezone, inv_type) VALUES(:fb_id ,:fb_gender,:fb_user_name, :fb_dob,
					:fb_email,:fb_location,:fb_timezone,:inv_type);');
				if(!$sth){
					$Log->lwrite($dbh->errorInfo());
				}
	        	$fb_user = $facebook->api('/me');
				$fb_gender=null;$fb_user_name=null;$fb_dob=null;
				$fb_email=null;$fb_location=null;$fb_timezone=null;$inv_type=0;
				if(isset($fb_user['gender'])) $fb_gender=$fb_user['gender'];
				if(isset($fb_user['name'])) $fb_user_name=$fb_user['name'];
				if(isset($fb_user['birthday'])) $fb_dob=$fb_user['birthday'];
				if(isset($fb_user['email'])) $fb_email=$fb_user['email'];
				if(isset($fb_user['timezone'])) $fb_timezone=$fb_user['timezone'];
		    	$Loc = $facebook->api($fb_id, 'get', array("fields"=>"location"));
				if($Loc){
					$locArr=$Loc['location'];
					if($locArr){
						$fb_location=$locArr['name'];
					}
				}
				$sth->bindParam(':fb_id', $fb_id, PDO::PARAM_INT);
				$sth->bindParam(':fb_gender', $fb_gender, PDO::PARAM_STR);
				$sth->bindParam(':fb_user_name', $fb_user_name, PDO::PARAM_STR);
				$sth->bindParam(':fb_dob', $fb_dob, PDO::PARAM_STR);
				$sth->bindParam(':fb_email', $fb_email, PDO::PARAM_STR);
				$sth->bindParam(':fb_location', $fb_location, PDO::PARAM_STR);
				$sth->bindParam(':fb_timezone', $fb_timezone, PDO::PARAM_STR);
				$sth->bindParam(':inv_type', $inv_type, PDO::PARAM_INT);
				if($sth->execute()){
					$Log->lwrite("insert user succeeded for:".$fb_id);
					$sth = $dbh->prepare("SELECT user_id, fb_id FROM user WHERE fb_id= :id");
					$sth->bindParam(':id', $fb_id, PDO::PARAM_INT);
					$sth->execute();
					$user_record = $sth->fetchAll(PDO::FETCH_ASSOC);
					if(!$user_record || count($user_record)==0){
						$Log->lwrite("No record found for fb:".$fb_id);
					}
					else{
						$sth = $dbh->prepare('INSERT INTO session(user_id,fb_id, access_token)
							VALUES(:user_id ,:fb_id,:access_token)');
						$sth->bindParam(':user_id', $user_record[0]['user_id'], PDO::PARAM_INT);
						$sth->bindParam(':fb_id', $fb_id, PDO::PARAM_INT);
						$sth->bindParam(':access_token', $session['access_token'], PDO::PARAM_STR);
						if(!$sth->execute()){
							$Log->lwrite("failed to insert session for fb:".$fb_id);
							$ErrorInfo= array();
							$ErrorInfo=$sth->errorInfo();
							$Log->lwrite("error info:".$ErrorInfo{2});
						}
						else{
							if($userCollection!=null){
								$fb_user["_id"]=$user_record[0]['user_id'];
								$fb_session = array("_id"=>$session['access_token'], "create_time"=>date('D,d M Y H:i:s'));
								$fb_session_arr = Array();
								array_push($fb_session_arr, $fb_session);
								$fb_user["sessions"]=$fb_session_arr;
								$userCollection->insert($fb_user);
							}
						}
					}
				}
				else{
					$Log->lwrite("insert user failed for:".$fb_id);
					$ErrorInfo= array();
					$ErrorInfo=$sth->errorInfo();
					$Log->lwrite("error info:".$ErrorInfo{2});
				}
			}
			else{
				$userId=$userResult[0]['user_id'];
				$sth = $dbh->prepare("update session set access_token=:access_token where fb_id=:fb_id");
				$sth->bindParam(':access_token', $session['access_token'], PDO::PARAM_STR);
				$sth->bindParam(':fb_id', $fb_id, PDO::PARAM_INT);
				if($sth->execute()){
					$Log->lwrite("update user session succeeded");
					if($userCollection!=null){
						$updateQuery=array("_id"=>$userId);
						$sessionDate = date("c", time());
						$setQuery=array('$push'=>array("sessions"=>array("id"=>$session['access_token'],
										"create_time"=>$sessionDate)));
						try{
							$userCollection->update($updateQuery,$setQuery);
						    $Log->lwrite('Mongo Updated with new session');
						}
						catch (MongoException $e) {
						    $Log->lwrite('Mongo Error: '.$e->getMessage());
						}
						catch (Exception $ex){
						    $Log->lwrite('Mongo Error: ' . $ex->getMessage());
						}
					}
				}
				else{
					$Log->lwrite($dbh->errorInfo());
					$ErrorInfo= array();
					$ErrorInfo=$sth->errorInfo();
					$Log->lwrite("error info:".$ErrorInfo{2});
				}
			}
		}
	}
	echo "
		<HEAD>
			<script src='HTTPS://connect.facebook.net/en_US/all.js'></script>
			<script type='text/javascript'>
			function framesetsize(w,h){
				var obj =   new Object;
				obj.width=w;
				obj.height=h;
				FB.Canvas.setSize(obj);
			}
			function inviteFriends(appId, accessToken, _message) {
	     		FB.init({ app_id:appId, cookie:true, status:true, oauth:true });
				FB.ui({ method: 'apprequests', title: 'Invite your friends to Big Bollywood Break!', access_token:accessToken, display: 'iframe', message: _message},earnCallback);
			}

			function placeOrder(userData, fbCredits, appId, _title, _desc) {
			 	var obj = {
				   	method: 'pay',
				   	order_info: {price: fbCredits, title: _title,
				   				item_name: 'Flash Points',
				   				description: _desc,
				   				data:userData},
				   	purchase_type: 'item',
				   	app_id: appId
			 	};
			 	FB.ui(obj, callback);
		    }

			function getPublishPermission(appId){
				 FB.init({ appId:appId, cookie:true, status:true, oauth:true });
				 var obj = {
				     method: 'permissions.request',
				     scope: 'publish_stream'
				 };
				 FB.ui(obj, function (response) {
				 }
				);
			}

			function earnCredits(appId){
			    var obj = {
			         method: 'pay',
			         credits_purchase: true,
			         dev_purchase_params: {shortcut:'offer'},
			         app_id: appId
			    };
			    FB.ui(obj, earnCallback);
			 }

			function buyCredits(appId){
			    var obj = {
			         method: 'pay',
			         credits_purchase: true,
			         app_id: appId
			    };
			    FB.ui(obj, earnCallback);
			 }

		    var earnCallback = function(data) {
		    }

		    var callback = function(data) {
		    	if (data['order_id']) {
		        	// Success, we received the order_id. The order states can be
		        	// settled or cancelled at this point.
		        	return true;
		      	} else {
		        	//handle errors here
		        	return false;
		      	}
		    }

			function scrollTo(){
				FB.Canvas.scrollTo(0,0);
			}
			</script>
			<TITLE>Rementos - Relive your moments</TITLE>
			<script src='AC_OETags.js' language='javascript'></script>
			<script language='JavaScript' type='text/javascript'>
			<!--
				// -----------------------------------------------------------------------------
				// Globals
				// Major version of Flash required
				var requiredMajorVersion = 10;
				// Minor version of Flash required
				var requiredMinorVersion = 3;
				// Minor version of Flash required
				var requiredRevision = 124;
				// -----------------------------------------------------------------------------
			// -->
			</script>
		</HEAD>
		<body onload='framesetsize(760,600)'>
		<script language='JavaScript' type='text/javascript'>
			<!--
				var hasProductInstall = DetectFlashVer(10, 2, 0);
				// Version check based upon the values defined in globals
				var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);
				if ( hasProductInstall && !hasRequestedVersion ) {
					// DO NOT MODIFY THE FOLLOWING FOUR LINES
					// Location visited after installation is complete if installation is required
					var MMPlayerType = (isIE == true) ? 'ActiveX' : 'PlugIn';
					var MMredirectURL = window.location;
					document.title = document.title.slice(0, 47) + ' - Flash Player Installation';
					var MMdoctitle = document.title;

					AC_FL_RunContent(
						'src', 'playerProductInstall',
						'FlashVars', 'MMredirectURL='+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+'',
						'width', '760',
						'height', '600',
						'align', 'middle',
						'id','InvigTest',
						'quality', 'high',
						'bgcolor', '#869ca7',
						'name', 'BollyGame',
						'allowScriptAccess','sameDomain',
						'type', 'application/x-shockwave-flash',
						'pluginspage', 'https://www.adobe.com/go/getflashplayer'
					);
				} else if (hasRequestedVersion) {
					// if we've detected an acceptable version
					// embed the Flash Content SWF when all tests are passed
					AC_FL_RunContent(
							'src', '$InvigUrl',
							'width', '760',
							'height', '600',
							'align', 'middle',
							'id','InvigTest',
							'quality', 'high',
							'bgcolor', '#869ca7',
							'name', 'Invig',
							'wmode', 'transparent',
							'allowScriptAccess','sameDomain',
							'type', 'application/x-shockwave-flash',
							'pluginspage', 'https://www.adobe.com/go/getflashplayer'
					);
				  } else {  // flash is too old or we can't detect the plugin
					var alternateContent = 'Alternate HTML content should be placed here. '
					+ 'This content requires the Adobe Flash Player. '
					+ '<a href=https://www.adobe.com/go/getflash/>Get Flash</a>';
					document.write(alternateContent);  // insert non-flash content
				  }
				// -->
			</script>
		<div id='fb-root'></div>
		</body>
		</HTMl>";
?>