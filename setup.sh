#!/bin/sh
#
# 	Instant Wordpress!
# 	------------------
# 	My script for installing the latest version of WordPress plus a number of plugins I find useful.
#
# 	To use this script, go to the directory you want to install Wordpress to in the terminal and run this command:
#
# 	curl mehmetkilic.com.tr | sh
#
# 	There you go.
#


#!/bin/bash -e
clear
echo "============================================"
echo "Hızlı Wordpress Kurulumu"
echo "============================================"
echo "Yeni veritabanı oluşturulacak mı ? (y/n)"
read -e setupmysql
if [ "$setupmysql" == y ] ; then
	echo "MySQL Root Kullanıcı Adı: "
	read -e mysqluser
	echo "MySQL Root Şifresi: "
	read -s mysqlpass
	echo "MySQL Host (Varsayılan için enter 'localhost'): "
	read -e mysqlhost
		mysqlhost=${mysqlhost:-localhost}
fi
echo "WP Veritabanı Adı: "
read -e dbname
echo "WP Veritabanı Kullanıcısı: "
read -e dbuser
echo "WP Veritabanı Şifresi: "
read -s dbpass
echo "WP Veritabanı Tablosu Ön eki (Varsayılan için enter 'wp_'): "
read -e dbtable
	dbtable=${dbtable:-wp_}
echo "Ayarları kaydetmek istediğinizden eminmisiniz ? (y/n)"
read -e run
if [ "$run" == y ] ; then
	if [ "$setupmysql" == y ] ; then
		echo "============================================"
		echo "Veritabanı oluşturuluyor"
		echo "============================================"
		#login to MySQL, add database, add user and grant permissions
		dbsetup="create database $dbname;GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@$mysqlhost IDENTIFIED BY '$dbpass';FLUSH PRIVILEGES;"
		mysql -u $mysqluser -p$mysqlpass -e "$dbsetup"
		if [ $? != "0" ]; then
			echo "============================================"
			echo "[Hata]: Veritabanı oluşturulamadı, lütfen bilgileri kontrol edip tekrar deneyin."
			echo "============================================"
			exit 1
		fi
	fi
	echo "============================================"
	echo "Hızlı Wordpress Kurulumu"
  echo "@mehmetkilic"
	echo "============================================"

  # Wordpress indiriliyor
  echo "Wordpress indiriliyor...";
  wget --quiet http://mehmetkilic.com.tr/wordpress.zip;
  unzip -q wordpress.zip;
  echo "Wordpress indirildi ve çıkarıldı.";
	# Wordpress ana dizine taşınıyor
	echo "Dosyalar çıkarılıyor..."
	mv wordpress/* ./

  #####  Pluginler indirilip kuruluyor ####
  # All-in-One-SEO-Pack
  echo "Eklentiler indiriliyor.";
  echo "All-in-One-SEO-Pack eklentisi indiriliyor...";
  wget --quiet http://downloads.wordpress.org/plugin/all-in-one-seo-pack.zip;
  unzip -q all-in-one-seo-pack.zip;
  mv all-in-one-seo-pack wordpress/wp-content/plugins/

  # Sitemap Generator
  echo "Google Sitemap Generator eklentisi indiriliyor...";
  wget --quiet http://downloads.wordpress.org/plugin/google-sitemap-generator.zip;
  unzip -q  google-sitemap-generator.zip;
  mv google-sitemap-generator wordpress/wp-content/plugins/

  # Secure WordPress
  echo "Secure WordPress eklentisi indiriliyor...";
  wget --quiet http://downloads.wordpress.org/plugin/secure-wordpress.zip;
  unzip -q  secure-wordpress.zip;
  mv secure-wordpress wordpress/wp-content/plugins/

  # Super-cache
  echo "Super Cache eklentisi indiriliyor...";
  wget --quiet http://downloads.wordpress.org/plugin/wp-super-cache.zip;
  unzip -q  wp-super-cache.zip;
  mv wp-super-cache wordpress/wp-content/plugins/
  #####  Pluginler indirilip kuruluyor ####


	echo "Config dosyası ayarlanıyor..."
	#create wp config
	cp wp-config-sample.php wp-config.php
	#set database details with perl find and replace
	perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
	perl -pi -e "s/username_here/$dbuser/g" wp-config.php
	perl -pi -e "s/password_here/$dbpass/g" wp-config.php
	perl -pi -e "s/wp_/$dbtable/g" wp-config.php
	#create uploads folder and set permissions
	mkdir wp-content/uploads
  echo "Yazma izinleri verildi..."
  chmod 777 wp-content/uploads
	echo "Gereksiz dosyalar siliniyor..."
	#remove wordpress/ dir
	rmdir wordpress
	#remove zip file
	rm wordpress.zip
	#remove bash script if it exists in this dir
	[[ -f "$file" ]] && rm "setup.sh"
	echo "========================="
	echo "[Başarılı]: Kurulum başarıyla tamamlandı !"
	echo "========================="
else
	exit
fi
