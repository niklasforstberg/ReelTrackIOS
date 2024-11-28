This app will let a family keep a history of movies they have watched together. A family can have several family members. A family can have many different lists, depending on the constellation they watched the movie in. The list should keep track of the movie, the date it was watched and who chose the movie. The information we keep about a movie is the title and the IMDb id. The list knows what family members are in the list.

This project will use .net 8 with minimal APIs, and EF Core for the database. An iOS app will be used as a frontend. Each family member will have their own account. A family member will be able to log in using email and a password. A family member will be able to create a family, and invite other family members to the family. A family member will be able to see all the lists for the family they belong to. Once a user has a family they cannot create a new family. The user that creates a family is the family admin. The family admin will be able to add and remove family members.
We should not use soft deletes. 
A watchlist should have a name.
A family should have an invite code, which can be used to join the family. This should not be too long.

A movie can be watched many times for each list.

The most important aspect of this app is to keep track of whose turn it is to choose the next movie. The family admin can decide the turn order for each list.

I wanto to use SQLite to start with, and move to SQL Server once it is in production.


