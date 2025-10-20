# Физический уровень PostgreSQL


## Установка Ubuntu 24.04 в VMWare Fusion 11.5 (macOS)

Запуск мастера создания машины (cmd + N)

!['Новая ВМ'](1_1_1_Create_new_VM_Ubuntu.PNG)

Выбор скачанного заранее установочного образа Ubuntu

!['Выбор образа ISO'](1_1_2_choose_distributive.PNG)

Выбор BIOS

!['Выбор BIOS'](1_1_3_choose_firmware_type.PNG)

Дополнительная настройка (кнопка "Customize Settings")

!['Выбор доп.настроек'](1_1_4_customize_settings.PNG)

Выбор места сохранения файлов ВМ

!['Выбор места хранения'](1_1_5_choose_storage_for_VM.PNG)

Настройка ЦП, памяти и возможностей запуска ВМ внутри (ЦП = 2; Память = 4 ГБ)

!['Настройка ЦП и памяти'](1_1_6_CPU_Memory_config.PNG)

Настройка диска ВМ (размер = 15 ГБ, тип = NVMe)

!['Настройка диска'](1_1_7_set_virtual_disk_type_and_size.PNG)

Обзор конфигурации

!['Обзор конфигурации'](1_2_1_disk_config.PNG)

Запуск ВМ и установка Ubuntu

!['Запуск и установка'](1_3_Start_VM_and_install_Ubuntu.PNG)

Установка VM Tools

	sudo apt install open-vm-tools-desktop -y

_Требуется перезапуск ВМ._


## Установка PostgreSQL 15 в Ubuntu


### Регистрация официальных пакетов в локальном репозитории apt

	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

	wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

	sudo apt update && sudo apt upgrade -y


### Установка СУБД и клиента версии 15

	sudo apt install postgresql-15 postgresql-client-15 -y

Настройка запуска СУБД и проверка версии клиента

	sudo systemctl enable postgresql
	sudo systemctl status postgresql
	psql --version

!['Настройка запуска и проверка версии'](4_2_enable_postgreSQL.PNG)

Проверка кластера

	sudo -u postgres pg_lsclusters

	Ver Cluster Port Status Owner    Data directory              Log file
	15  main    5432 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log

Изменение пароля пользователя в СУБД

	sudo -u postgres psql

Создание таблицы test

	create table test(c1 text);
	insert into test values('1'),('2');

!['Создание таблицы test'](4_3_create_table_test.PNG)


## Добавление дополнительного диска в Ubuntu 24.04 в VMWare Fusion 11.5 (macOS)


### Создание дополнительного диска

1. Настройки ___остановленной___ ВМ
!['Настройки ВМ'](1_2_1_disk_config.PNG)

2. Выбор типа добавляемого устройства (New hard disk)
!['Тип устройства'](5_1_0_select_device_to_add.PNG)

3. Настройка диска ВМ (размер = 10 ГБ, тип = NVMe, Split into multiple files = [ ]). _Внимание! Обязательно отключить опцию "Split into multiple files" для получения единого файла диска._
!['Настройка диска'](5_1_1_add_new_virtual_disk_to_VM.PNG)

4. Выбор папки, отличной от бандла ВМ, для сохранения файла диска
!['Выбор папки для файла диска'](5_1_2_choose_folder_out_of_VM.PNG)

5. Сохранение файла диска
!['Сохранение файла диска'](5_1_3_save_folder_out_of_VM.PNG)

6. Проверка наличия файла диска
!['Наличие файла'](5_1_4_check_new_disk.PNG)


### Разметка нового диска

Определение имени диска

	sudo lsblk

!['Список устройств'](6_1_list_disks.png)

Форматирование диска

	sudo mkfs -t ext4 /dev/nvme0n2

!['Форматирование'](6_2_format_disk.PNG)

Создание точки монтирования и предоставление прав

	sudo mkdir /mnt/edisk2

Монтирование диска

	sudo mount -t ext4 /dev/nvme0n2 /mnt/edisk2
	sudo chown -R postgres:postgres /mnt/edisk2

Перезагрузка ВМ

Диск после перезагрузки монтируется для пользователя в папку /media/postgresql

Автоматическое монтирование диска

	sudo nano /etc/fstab

Регистрация автоматического монтирования диска в файле /etc/fstab

!['Регистрация автоматического монтирования диска в файле /etc/fstab'](6_3_fstab.PNG)

Перезагрузка ВМ


## Перенос кластера PostgreSQL на новый диск

Остановка кластера

	sudo -u postgres pg_ctlcluster 15 main stop

Перенос содержимого на новый диск

	sudo mv /var/lib/postgresql/15 /mnt/edisk2

Запуск кластера PostgreSQL

	sudo -u postgres pg_ctlcluster 15 main start
	Error: /var/lib/postgresql/15/main is not accessible or does not exist

_Настройки кластера указывают на папку, из которой данные перенесли. Данные отсутствуют._

Настройка положения новой папки с данными (_параметр data_directory в файле postgresql.conf_)

	sudo nano /etc/postgresql/15/main/postgresql.conf

!['Настройка положения папки с данными в файле /etc/postgresql/15/main/postgresql.conf'](7_1_postgresql_conf.PNG)

Запуск кластера PostgreSQL

	sudo -u postgres pg_ctlcluster 15 main start
	Warning: the cluster will not be running as a systemd service. Consider using systemctl:
  		sudo systemctl start postgresql@15-main

_Не обнаружено роблем с автоматическим запуском кластера после перезапуска ВМ._


Проверка данных в таблице test

	sudo -u postgres psql

	psql (15.14 (Ubuntu 15.14-1.pgdg24.04+1))
	Type "help" for help.
	postgres=# select * from test;
	 c1 
	----
	 1
	 2
	 3
	(3 rows)


## Перенос данных кластера PostgreSQL в кластер на другой ВМ


### Создание ВМ (_аналогично предыдущей, с другим именем пользователя_)

Запуск мастера создания машины (cmd + N)

!['Новая ВМ'](1_1_1_Create_new_VM_Ubuntu.PNG)

Выбор скачанного заранее установочного образа Ubuntu

!['Выбор образа ISO'](1_1_2_choose_distributive.PNG)

Выбор BIOS

!['Выбор BIOS'](1_1_3_choose_firmware_type.PNG)

Дополнительная настройка (кнопка "Customize Settings")

!['Выбор доп.настроек'](1_1_4_customize_settings.PNG)

Выбор места сохранения файлов ВМ

!['Выбор места хранения'](1_1_5_choose_storage_for_VM_target.PNG)

Настройка ЦП, памяти и возможностей запуска ВМ внутри (ЦП = 2; Память = 4 ГБ)

!['Настройка ЦП и памяти'](1_1_6_CPU_Memory_config.PNG)

Настройка диска ВМ (размер = 15 ГБ, тип = NVMe)

!['Настройка диска'](1_1_7_set_virtual_disk_type_and_size.PNG)

Обзор конфигурации

!['Обзор конфигурации'](1_2_1_disk_config.PNG)

Запуск ВМ и установка Ubuntu

!['Запуск и установка'](1_3_Start_VM_and_install_Ubuntu.PNG)

Установка VM Tools

	sudo apt install open-vm-tools-desktop -y

_Требуется перезапуск ВМ._


### Установка PostgreSQL 15 в Ubuntu


#### Регистрация официальных пакетов в локальном репозитории apt

	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

	wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

	sudo apt update && sudo apt upgrade -y


#### Установка СУБД и клиента версии 15

	sudo apt install postgresql-15 postgresql-client-15 -y

Настройка запуска СУБД и проверка версии клиента

	sudo systemctl enable postgresql
	sudo systemctl status postgresql
	psql --version


### Подключение дополнительного диска в Ubuntu 24.04 в VMWare Fusion 11.5 (macOS) (_из остановленной ВМ_)

1. Настройки остановленной ВМ
!['Настройки ВМ'](8_1_config_target.PNG)

2. Выбор типа добавляемого устройства (Existing hard disk)
!['Тип устройства'](8_2_attach_disk.PNG)

3. Выбор файла диска остановленной ВМ (_режим совместного использования_)
!['ВВыбор файла диска остановленной ВМ'](8_3_set_disk_sharing_mode.PNG)

4. Регистрация диска ВМ (размер = 10 ГБ, тип = NVMe, Split into multiple files = [ ]). _Внимание! Соглашаемся с типом = SCSI, затем возвращаем NVMe._
!['Регистрация диска'](8_4_apply_disk.PNG)
!['Настройка типа NVMe'](8_4_set_nvme_mode.PNG)


5. Обзор конфигурации
!['Обзор конфигурации'](8_5_check_config.PNG)


### Монтирование дополнительного диска

Создание точки монтирования и предоставление прав (_используем другое имя папки монтирования_)

	sudo mkdir /mnt/data

Монтирование диска

	sudo mount -t ext4 /dev/nvme0n2 /mnt/data

Автоматическое монтирование диска

	sudo nano /etc/fstab

Регистрация автоматического монтирования диска в файле /etc/fstab (_UUID остался прежним_)

!['Регистрация автоматического монтирования диска в файле /etc/fstab'](9_1_fstab.PNG)

Перезагрузка ВМ


### Подключение данных кластера PostgreSQL с нового диска

Остановка кластера

	sudo -u postgres pg_ctlcluster 15 main stop

Удаление папки с данными кластера

	sudo rm -r /var/lib/postgresql/15

Настройка положения новой папки с данными (_параметр data_directory в файле postgresql.conf_)

	sudo nano /etc/postgresql/15/main/postgresql.conf

!['Настройка положения папки с данными в файле /etc/postgresql/15/main/postgresql.conf'](9_2_postgresql_conf.PNG)

Запуск кластера PostgreSQL

	sudo -u postgres pg_ctlcluster 15 main start
	Warning: the cluster will not be running as a systemd service. Consider using systemctl:
  		sudo systemctl start postgresql@15-main

_Перезапуск ВМ приводит к автоматическому запуску кластера._

Проверка наличия таблицы test в базе postgres

	sudo -u postgres psql

	psql (15.14 (Ubuntu 15.14-1.pgdg24.04+1))
	Type "help" for help.
	postgres=# \dt
        List of relations
	 Schema | Name | Type  |  Owner   
	--------+------+-------+----------
	 public | test | table | postgres
	(1 row)

Проверка данных в таблице test

	postgres=# select * from test;
	 c1 
	----
	 1
	 2
	 3
	(3 rows)
