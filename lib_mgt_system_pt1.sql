select * from return_status

---add foreign key constrains:
alter table issued_status
add constraint fk_members
foreign key(issued_member_id)
references members(member_id)

alter table issued_status
add constraint fk_books
foreign key([issued_book_isbn])
references books(isbn)

alter table issued_status
add constraint fk_employees
foreign key(issued_emp_id)
references employees(emp_id)

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id)

--alter table return_status
--add constraint fk_issued_status
--foreign key(issued_id)
--references issued_status(issued_id)

---task 1: insert a new book
insert into books
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

select * from books

---task 2: update and existing members adress
select * from members

update members
set member_address = '125 Main st'
where member_id = 'C101'

---task 3: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121'

---task 4: Select all books issued by the employee with emp_id = 'E101
select * from employees
select * from issued_status

select issued_book_name 
from issued_status 
where issued_emp_id = 101

---task 5: List employees Who Have Issued More Than One Book
select i.issued_emp_id,	
		e.emp_name
from issued_status i
join Employees e
on i.issued_emp_id = e.emp_id
group by i.issued_emp_id, e.emp_name
having count(i.issued_emp_id) > 1

---task 6: create a temp table that list books that have been issued and how many times they've been issued
select * from books
select * from issued_status

-- Corrected version for SQL Server
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
INTO book_cnts
FROM books as b
JOIN issued_status as ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

select * from book_cnts

---task 7: retrieve all books in a specific category
select category, count(*) as number_of_books
from books
group by category

---Task 8: Find Total Rental Income by Category:
select b.category, sum(b.rental_price) as total_income
from books b
join issued_status i
on b.isbn = i.issued_book_isbn
group by b.category

---List Members Who Registered more than 2 years ago:
select * from members

select * 
from members
WHERE reg_date < DATEADD(YEAR, -2, GETDATE())

---task 10 List Employees with Their Branch Manager's Name and their branch details:
select * from Employees
select * from branch

select e1.*,
		b.branch_id,
		e2.emp_name as manager
from Employees e1
	join branch b
	on e1.branch_id = b.branch_id
	join Employees e2
	on b.manager_id = e2.emp_id

---Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
select * from books


select book_title, category, author, publisher
into book_price_greater_than_7
from books
where rental_price > 7

select * from book_price_greater_than_7

-- Task 12: Retrieve the List of Books Not Yet Returned
select * from issued_status
select * from return_status

select distinct issued_book_name
from issued_status i
left join return_status r
on i.issued_id = r.issued_id
where r.issued_id is null

