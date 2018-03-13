BetterMeans
-----------

BetterMeans is giving birth to a new kind of company. An Open Enterprise.

Getting started
---------------

Instructions for getting started are below:

#### Setup

Bettermeans includes a Vagrantfile that contains all the information you need to set up your own development Virtual Machine.  
To get started, follow the instructions below:

* git clone git@github.com:akio-outori/bettermeans.git
* Bring up a development VM - `vagrant up`

#### Starting the Application

All files for the application are stored in /vagrant.  This directory is synced to the  
repo files downloaded via git above.  **Changes to files on your VM will change your local  
git branch**.

* Use Vagrant to ssh into the vm - `vagrant ssh`
* cd to `/vagrant`
* run `./scripts/server -d`

#### Accessing the Application

If the steps above succeeded, the Bettermeans application will be running on http://localhost:8080  
in your browser.


That's it. Now you're ready to change the world. Here's to making a dent in things together!

Dev notes
---------

Bettermeans is currently in the process of being updated to a modern version of Ruby.  See the issue board for details on getting started or contact the maintainers via the WNC Tech slack or
email `jeffhallyburton@gmail.com` to get started.

License and legalese
--------------------

Our codebase is based largely on an early fork of Redmine.

Redmine is open source and released under the terms of the GNU General Public License v2 (GPL).
All redmine code is Copyright (C) 2006-2011  Jean-Philippe Lang
All non-redmine code is Copyright (C) Shereef Bishay, and is dual-licensed: you may use either the GNU General Public License v2 (GPL), or the MIT License (see http://www.opensource.org/licenses/mit-license.php).

Thanks for joining us! May our work be used for the greater good of everyone.
