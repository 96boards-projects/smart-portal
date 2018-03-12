<?php

	/**
	* Make sure you started your'e sessions!
	* You need to include su.inc.php to make SimpleUsers Work
	* After that, create an instance of SimpleUsers and your'e all set!
	*/

	session_start();
	require_once(dirname(__FILE__)."/simpleusers/su.inc.php");

	$SimpleUsers = new SimpleUsers();

	// This is a simple way of validating if a user is logged in or not.
	// If the user is logged in, the value is (bool)true - otherwise (bool)false.
	if( !$SimpleUsers->logged_in )
	{
		header("Location: login.php");
		exit;
	}

	// If the user is logged in, we can safely proceed.


	$userId = $_GET["userId"];

	$user = $SimpleUsers->getSingleUser($userId);
	if( !$user )
		die("The user could not be found...");


	// Validation of input
	if( isset($_POST["password"]) )
	{
		if( empty($_POST["password"]) )
			$error = "You have to choose a password";
    else
    {
    	// Input validation is ok, set the password and then redirect
			$SimpleUsers->setPassword($_POST["password"], $user["userId"]);
			header("Location: users.php");
			exit;
		}

	} // Validation end

?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset="UTF-8">
	<title>Login</title>
	<link rel="stylesheet" href="css/bootstrap.css">
	<style type="text/css">
		body{ font: 14px sans-serif; padding: 20px;}
		.wrapper{ width: 300px;}
	</style>
</head>
<body>
	<div>
		<p><a href="home.php" class="btn btn-primary">Home</a>
		<a href="users.php" class="btn btn-default">Users (admin only)</a>
		<a href="logout.php" class="btn btn-danger">Logout</a></p>
	</div>
<h2>Change password for user <?php echo $user["uUsername"]; ?></h2>
	<div class="wrapper">
		<?php if( isset($error) ): ?>
		<p>
			<?php echo $error; ?>
		</p>
		<?php endif; ?>

		<form method="post" action="">
            <div class="form-group">
				<label for="password">New Password:</label><br />
				<input type="text" name="password" id="password" class="form-control"/>
			</div>
			<div class="form-group">
				<input type="submit" class="btn btn-primary name="submit" value="Save" />
			</div>
			
		</form>
	</div>
</body>
</html>