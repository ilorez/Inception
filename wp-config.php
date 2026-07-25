<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'znajdaou' );

/** Database password */
define( 'DB_PASSWORD', 'user123' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'P9o6r$wH7G= CCSbMgj8?8h=C sp%g<+Z9 (j9m9gPZ?@nV*HnXRo&-doX@v%c}O' );
define( 'SECURE_AUTH_KEY',   'x@4b0Lt kyte.-!I)zVEm~ZxFh.0%[-5YvXSp};A>9KOv.N,H2 B+^ZE@wBiIJ>8' );
define( 'LOGGED_IN_KEY',     '>q)x?.eDG>ok5a&])sW&}a=tcY *)nVsU;7q##:C3:wPxKc*=`!{aOA[1T_w2!eg' );
define( 'NONCE_KEY',         'Wv9b7y?~l06,AnDtk7-xG4#Tg>~,vf2}lcwuJ~ iVPoW-VYWU%!y Yi)dU]i80^i' );
define( 'AUTH_SALT',         '}NTVu,;6xk yfUAOfw=IM4827Uf|8PnO$+Znf`jPT-1k_l%K;C:RJ@)/7x(0$)_6' );
define( 'SECURE_AUTH_SALT',  'z_*ahrb2<..HQ@^Mk5*wRg3ic}Px7<He0]Mnl}cuDXx^?hOlHfp@-fpUAM!$;;5k' );
define( 'LOGGED_IN_SALT',    'aFhWry>ptrO-RfVJKF$_L{>4?io)o_@f58R5^ZO5*OkWpb19x2Flxe6 #OITH c`' );
define( 'NONCE_SALT',        'MD,PlK{{Q$h&@&!K[iyP1KCH1AmWX_*:f5P-tL7>5u)@3_0 ?s0DT;k3LJIE(:s4' );
define( 'WP_CACHE_KEY_SALT', '5dF96,l1jFJvn2;6dM7qo=j^n]+}8A~1i#<?n/$UEEnkW6`Yo`S4R0xFlEYe0KRW' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

define( 'WP_REDIS_HOST', 'redis' );
define( 'WP_REDIS_PORT', 6379 );
define( 'WP_CACHE', true );
/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
