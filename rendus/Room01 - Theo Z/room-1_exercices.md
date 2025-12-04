Room 01 - Exercices HBase - Theo Zimmermann

Exercice 1 : Création de la table
create 'customers', 'info', 'contact'
describe 'customers'

Exercice 2 : Insertions de données
put 'customers', 'CUST001', 'info:name', 'Jean Dupont'
put 'customers', 'CUST001', 'info:city', 'Paris'
put 'customers', 'CUST001', 'info:country', 'France'
put 'customers', 'CUST001', 'contact:email', 'jean.dupont@email.com'

put 'customers', 'CUST002', 'info:name', 'Marie Martin'
put 'customers', 'CUST002', 'info:city', 'Lyon'
put 'customers', 'CUST002', 'info:country', 'France'
put 'customers', 'CUST002', 'contact:email', 'marie.martin@email.com'

put 'customers', 'CUST003', 'info:name', 'Pierre Durand'
put 'customers', 'CUST003', 'info:city', 'Marseille'
put 'customers', 'CUST003', 'info:country', 'France'
put 'customers', 'CUST003', 'contact:email', 'pierre.durand@email.com'

put 'customers', 'CUST004', 'info:name', 'Sophie Bernard'
put 'customers', 'CUST004', 'info:city', 'Toulouse'
put 'customers', 'CUST004', 'info:country', 'France'
put 'customers', 'CUST004', 'contact:email', 'sophie.bernard@email.com'

put 'customers', 'CUST005', 'info:name', 'Luc Moreau'
put 'customers', 'CUST005', 'info:city', 'Nice'
put 'customers', 'CUST005', 'info:country', 'France'
put 'customers', 'CUST005', 'contact:email', 'luc.moreau@email.com'

count 'customers'
scan 'customers'

Exercice 3 : Récupération des données
get 'customers', 'CUST002'
get 'customers', 'CUST003', {COLUMN => 'contact:email'}
get 'customers', 'CUST001', {COLUMN => 'info'}
count 'customers'

Exercice 4 : Mise à jour et suppression
put 'customers', 'CUST001', 'contact:email', 'jean.dupont+new@email.com'
put 'customers', 'CUST002', 'contact:phone', '0612345678'
delete 'customers', 'CUST002', 'contact:phone'
deleteall 'customers', 'CUST004'

Exercice 5 : Filtres
scan 'customers', {FILTER => "ValueFilter(=, 'binary:Paris')"}
scan 'customers', {COLUMNS => 'info'}
scan 'customers', {LIMIT => 3}
scan 'customers', {COLUMNS => 'info', LIMIT => 2}
