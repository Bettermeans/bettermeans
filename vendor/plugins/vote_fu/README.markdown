vote_fu
=======

Allows an arbitrary number of entites (including Users) to vote on models. 

### Mixins
This plugin introduces three mixins to your recipe book: 

1. **acts\_as\_voteable** : Intended for content objects like Posts, Comments, etc. 
2. **acts\_as\_voter** : Intended for voting entities, like Users. 
3. **has\_karma**  : Intended for voting entities, or other objects that own the things you're voting on.

### Inspiration

This plugin started as an adaptation / update of act\_as\_voteable. It has grown different from that plugin in several ways: 

1. You can specify the model name that initiates votes. 
2. You can, with a little tuning, have more than one entity type vote on more than one model type. 
3. Adds "acts\_as\_voter" behavior to the initiator of votes.
4. Introduces some newer Rails features like named\_scope and :polymorphic keywords
5. Adds "has\_karma" mixin for identifying key content contributors

Installation
============
Use either the plugin or the gem installation method depending on your preference. If you're not sure, the plugin method is simpler. Whichever you choose, create the migration afterward and run it to create the required model.

### Via plugin
    ./script/plugin install git://github.com/peteonrails/vote_fu.git 

### Via gem
Add the following to your application's environment.rb:
    config.gem "peteonrails-vote_fu", :lib => 'vote_fu', :source => 'http://gems.github.com'

Install the gem:
    rake gems:install

### Create vote_fu migration
Create a new rails migration using your new vote_fu generator (Note: "VoteableModel" is the name of the model on which you would like votes to be cast, e.g. Comment):
    ./script/generate vote_fu VoteableModel

Run the migration:
    rake db:migrate

Usage
=====

## Getting Started

### Make your ActiveRecord model act as voteable.


    class Model < ActiveRecord::Base
 	  acts_as_voteable
    end


### Make your ActiveRecord model(s) that vote act as voter.

    class User < ActiveRecord::Base
 	  acts_as_voter
    end

    class Robot < ActiveRecord::Base
   	  acts_as_voter
    end

### To cast a vote for a Model you can do the following:

#### Shorthand syntax
	voter.vote_for(voteable)     # Adds a +1 vote
	voter.vote_against(voteable) # Adds a -1 vote
	voter.vote(voteable, t_or_f) # Adds either +1 or -1 vote true => +1, false => -1
	
#### ActsAsVoteable syntax
The old acts\_as\_voteable syntax is still supported:

    vote = Vote.new(:vote => true)
    m    = Model.find(params[:id])
    m.votes    << vote
    user.votes << vote

### Querying votes

#### Tallying Votes

You can easily retrieve voteable object collections based on the properties of their votes:	

    @items = Item.tally(
      {  :at_least => 1, 
          :at_most => 10000,  
          :start_at => 2.weeks.ago,
          :end_at => 1.day.ago,
          :limit => 10,
          :order => "items.name desc"
      })

This will select the Items with between 1 and 10,000 votes, the votes having been cast within the last two weeks (not including today), then display the 10 last items in an alphabetical list.

##### Tally Options:
    :start_at    - Restrict the votes to those created after a certain time
    :end_at      - Restrict the votes to those created before a certain time
    :conditions  - A piece of SQL conditions to add to the query
    :limit       - The maximum number of voteables to return
    :order       - A piece of SQL to order by. Eg 'votes.count desc' or 'voteable.created_at desc'
    :at_least    - Item must have at least X votes
    :at_most     - Item may not have more than X votes

#### Lower level queries
ActiveRecord models that act as voteable can be queried for the positive votes, negative votes, and a total vote count by using the votes\_for, votes\_against, and votes\_count methods respectively. Here is an example:

    positiveVoteCount = m.votes_for
    negativeVoteCount = m.votes_against
    totalVoteCount    = m.votes_count

And because the Vote Fu plugin will add the has_many votes relationship to your model you can always get all the votes by using the votes property:

    allVotes = m.votes

The mixin also provides these methods: 

    voter.voted_for?(voteable)  # True if the voter voted for this object. 
	voter.vote_count([true|false|"all"]) # returns the count of +1, -1, or all votes 

	voteable.voted_by?(voter) # True if the voter voted for this object. 
	@voters = voteable.voters_who_voted


#### Named Scopes

The Vote model has several named scopes you can use to find vote details: 

    @pete_votes = Vote.for_voter(pete)
    @post_votes = Vote.for_voteable(post)
    @recent_votes = Vote.recent(1.day.ago)
    @descending_votes = Vote.descending

You can chain these together to make interesting queries: 

    # Show all of Pete's recent votes for a certain Post, in descending order (newest first)
    @pete_recent_votes_on_post = Vote.for_voter(pete).for_voteable(post).recent(7.days.ago).descending

### Experimental: Voteable Object Owner Karma
I have just introduced the "has\_karma" mixin to this package. It aims to assign a karma score to the owners of voteable objects. This is designed to allow you to see which users are submitting the most highly voted content. Currently, karma is only "positive". That is, +1 votes add to karma, but -1 votes do not detract from it. 

    class User 
      has_many :posts
      has_karma :posts
    end
    
    class Post
      acts_as_voteable
    end
    
    # in your view, you can then do this: 
    Karma: <%= @user.karma %>
  
This feature is in alpha, but useful enough that I'm releasing it. 

### One vote per user!
If you want to limit your users to a single vote on each item, take a look in lib/vote.rb. 

    # Uncomment this to limit users to a single vote on each item. 
    # validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id]

And if you want that enforced at the database level, look in the generated migration for your voteable:

    # If you want to enfore "One Person, One Vote" rules in the database, uncomment the index below
    # add_index :votes, ["voter_id", "voter_type", "voteable_id", "voteable_type"], :unique => true, :name => "uniq_one_vote_only"

### Example Application

There is now a reference application available. Due to overwhelming demand for example 
code and kickstart guides, I have open-sourced MyQuotable.com in order to provide an 
easy-to-follow example of how to use VoteFu with RESTful Authentication, JRails, and 
other popular plugins. To get the example code: 

    git clone git://github.com/peteonrails/myquotable.git

There will be a screencast coming soon too. Contact me if you want to help.

Consideration
=============
If you like this software and use it, please consider recommending me on Working With Rails. 

I don't want donations: a simple up-vote would make my day. My profile is: [http://www.workingwithrails.com/person/12521-peter-jackson][4]

To go directly to the "Recommend Me" screen: [http://www.workingwithrails.com/recommendation/new/person/12521-peter-jackson][5]


Credits
=======

#### Contributors

* Bence Nagy, Budapest, Hungary
* Jon Maddox, Richmond, Virginia, USA

#### Other works

[Juixe  - The original ActsAsVoteable plugin inspired this code.][1]

[Xelipe - This plugin is heavily influenced by Acts As Commentable.][2]

[1]: http://www.juixe.com/techknow/index.php/2006/06/24/acts-as-voteable-rails-plugin/
[2]: http://github.com/jackdempsey/acts_as_commentable/tree/master

More
====

Support: [Use my blog for support.][6]


[Documentation from the original acts\_as\_voteable plugin][3]

[3]: http://www.juixe.com/techknow/index.php/2006/06/24/acts-as-voteable-rails-plugin/
[4]: http://www.workingwithrails.com/person/12521-peter-jackson
[5]: http://www.workingwithrails.com/recommendation/new/person/12521-peter-jackson
[6]: http://blog.peteonrails.com

Copyright (c) 2008 Peter Jackson, released under the MIT license
