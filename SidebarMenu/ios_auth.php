<?php require_once('wp-load.php');
    
    $username = $_REQUEST["username"];
    $password = $_REQUEST["password"];
    $session = $_REQUEST["session"];
    
    if ($session == "") {
        login($username, $password);
    } else {
        check_session($session);
    }
    
    
    function login($username, $password) {
        
        // check to see if its an email or username check
        if(filter_var($username, FILTER_VALIDATE_EMAIL)) {
            $user = get_user_by('email',$username);
        } else {
            $user = get_user_by('login',$username);
        }
        
        $request = "Login";
        
        
        if ( $user and wp_check_password($password, $user->data->user_pass, $user->ID) ) {
            
            $mySessionID = md5("block");
            $myUserID = $username ;
            $response = "OK";
            $response_code = 200;
            
            $data = array('data' => array('session' => $mySessionID),
                          'request' => $request,
                          'response' => $response,
                          'response_code' => $response_code);
        } else {
            $request = "Login";
            $response = "not authenticated";
            $response_code = 530;
            $mySessionID = "0";
            $myUserID = "0";
            $data = array('request' => $request,
                          'response' => $response,
                          'response_code' => $response_code);
        }
        
        
        
        echo json_encode($data);
    }
    
    function check_session($session) {
        
        $request = "CheckSession";
        
        if ($session == md5("block")) {
            $response = "OK";
            $response_code = 200;	
            
        } else {
            $response = "not authenticated";
            $response_code = 593;	
        }
        
        $data = array('data' => array('some_data' => "valid request"), 
                      'request' => $request,
                      'response' => $response,
                      'response_code' => $response_code);
        
        echo json_encode($data);
        
    }
    ?>

