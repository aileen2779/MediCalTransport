<?php require_once('wp-load.php');
    global $wpdb;
    
    $user = $_REQUEST["user"];
    $ipAddress = $_SERVER['REMOTE_ADDR'];
    $timeStamp=date('Y-m-d H:i:s.') . gettimeofday()['usec'];
    
    echo $user;
    $wpdb->insert( 'tblShifterLog',
                  array(
                        'IPAddress' 	=> $ipAddress,
                        'Timestamp' 	=> $timeStamp,
                        'UserID' 		=> $user,
                        'Action' 		=> 'iPhone'
                        )
                  
                  );
    
    if ($user == NULL or $user == ""  or $user == "ALL") {
        $where_condition = "is not null";
    } else {
        $where_condition = "= '$user'";
    }
    
    $my_query = "SELECT id, user_email, IFNULL(waiver_form,\"\") as waiver_form from wp_ba35p47yx0_users where display_name != \"\" and user_login " . $where_condition;
    
    $data = array();
    foreach( $wpdb->get_results($my_query) as $key => $row) {
        
        $userid = $row->id;
        $waiver_form = $row->waiver_form;
        
        $member = MS_Factory::load( 'MS_Model_Member', $userid );
        
        $membership_start 	= "01/01/1900";		// placeholder
        $membership_end		= "99/99/9999";		// placeholder
        $membership_status	= "Active";		// placeholder
        $payment_gateway	= "Unknown";		// placeholder
        
        
        if ( $member->has_membership( MS_Controller_Api::get_membership_id("Solo") ) ) {
            $membership =  "Solo";
            $membership_paid =  "60";
        } elseif ( $member->has_membership( MS_Controller_Api::get_membership_id("Tandem") ) ) {
            $membership =  "Tandem";
            $membership_paid =  "50";
        } elseif ( $member->has_membership( MS_Controller_Api::get_membership_id("Vintage") ) ) {
            $membership =  "Vintage";
            $membership_paid =  "50";
        } elseif ( $member->has_membership( MS_Controller_Api::get_membership_id("Training Wheels") ) ) {
            $membership =  "Training Wheels";
            $membership_paid =  "0";
        } else {
            $membership 		=  	"None";
            $membership_paid 	=  	"0";
            $membership_start 	= 	"None";
            $membership_end		= 	"None";
            $membership_status	= 	"Inactive";
            $payment_gateway	= 	"None";
        }
        
        
        $myrows_meta = $wpdb->get_row( "SELECT
                                      user_id	as 'user_id',
                                      '$row->user_email'	as 'email',
                                      MAX(
                                          CASE
                                          WHEN meta_key ='nickname' THEN meta_value ELSE ''
                                          END
                                          ) AS 'user_name',
                                      MAX(
                                          CASE
                                          WHEN meta_key ='first_name' THEN meta_value ELSE ''
                                          END
                                          ) AS 'first_name',
                                      MAX(
                                          CASE WHEN meta_key ='last_name' THEN meta_value ELSE ''
                                          END
                                          ) AS 'last_name',
                                      MAX(
                                          CASE WHEN meta_key ='addr1' THEN meta_value ELSE ''
                                          END
                                          ) AS 'addr1',
                                      MAX(
                                          CASE WHEN meta_key ='city' THEN meta_value ELSE ''
                                          END
                                          ) AS 'city',
                                      MAX(
                                          CASE WHEN meta_key ='thestate' THEN meta_value ELSE ''
                                          END
                                          ) AS 'state',
                                      MAX(
                                          CASE WHEN meta_key ='zip' THEN meta_value ELSE ''
                                          END
                                          ) AS 'zip',
                                      MAX(
                                          CASE WHEN meta_key ='country' THEN meta_value ELSE ''
                                          END
                                          ) AS 'country',
                                      MAX(
                                          CASE WHEN meta_key ='phone1' THEN meta_value ELSE ''
                                          END
                                          ) AS 'phone1',
                                      MAX(
                                          CASE WHEN meta_key ='emergency_contact_name' THEN meta_value ELSE ''
                                          END
                                          ) AS 'emergency_contact_name',
                                      MAX(
                                          CASE WHEN meta_key ='emergency_contact_number' THEN meta_value ELSE ''
                                          END
                                          ) AS 'emergency_contact_number'
                                      from wp_ba35p47yx0_usermeta
                                      where user_id = $userid
                                      and meta_key in ('first_name',
                                                       'last_name',
                                                       'addr1',
                                                       'city',
                                                       'thestate',
                                                       'zip',
                                                       'country',
                                                       'phone1',
                                                       'ms_username',
                                                       'nickname',
                                                       'ms_email',
                                                       'emergency_contact_name',
                                                       'emergency_contact_number')", ARRAY_A  );
                                      
                                      
                                      //	echo $row->first_name;
                                      
                                      $data[] = array(
                                                      "user_id" => $myrows_meta['user_id'],
                                                      "email" => $myrows_meta['email'],
                                                      "user_name" => $myrows_meta['user_name'],
                                                      "first_name" => $myrows_meta['first_name'],
                                                      "last_name" => $myrows_meta['last_name'],
                                                      "addr1" => $myrows_meta['addr1'],
                                                      "city" => $myrows_meta['city'],
                                                      "state" => $myrows_meta['state'],
                                                      "zip" => $myrows_meta['zip'],
                                                      "country" => $myrows_meta['country'],
                                                      "phone1" => $myrows_meta['phone1'],
                                                      "emer_contact_name" => $myrows_meta['emergency_contact_name'],
                                                      "emer_contact_number" => $myrows_meta['emergency_contact_number'],
                                                      "membership" => $membership,
                                                      "membership_paid" => $membership_paid,
                                                      "membership" => $membership,
                                                      "membership_paid" => $membership_paid,
                                                      "membership_start" => $membership_start,
                                                      "membership_end" => $membership_end,
                                                      "membership_status" => $membership_status,
                                                      "payment_gateway" => $payment_gateway,
                                                      "waiver_form" => $waiver_form
                                                      );
                                      
                                      }
                                      echo json_encode($data);
                                      ?>

