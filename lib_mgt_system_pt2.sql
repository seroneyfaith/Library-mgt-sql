---this is the advanced sql code for the library management system

select * from issued_status
select * from members
select * from return_status
select * from books
--- task 13: identify members with overdue books assuming a 30-day return period
select i.issued_member_id,
		m.member_id,
		b.book_title,
		datediff(day, i.issued_date, getdate())
from issued_status i
join members m 
on i.issued_member_id = m.member_id
join books b
on i.issued_book_isbn = b.isbn
join return_status r
on i.issued_id = r.issued_id
where r.return_date is null
		and datediff(day, i.issued_date, getdate()) > 30
order by i.issued_member_id


/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
update books
set status = 'yes'
where isbn in(
		select i.issued_book_isbn
		from issued_status i
		join return_status r
		on i.issued_book_isbn = r.return_book_isbn
)

--task 15: insert return record:
insert into return_status (return_id, issued_id, return_book_name, return_date, return_book_isbn)
VALUES ('RS125', 'IS130', 'DND', GETDATE(), 'isbn-0234');

select * from issued_status


---task 16: create a stored procedure to add return records:
create procedure proc_add_return_records
	@return_id varchar(10),
	@issued_id varchar(10),
	@return_book_name varchar(50)
as
begin
	declare @isbn varchar(50)
	declare @book_name varchar(80)

	insert into return_status(return_id, issued_id, return_date, return_book_name)
	values(@return_id, @issued_id, GETDATE(), @return_book_name)

	select @isbn = issued_book_isbn,
			@book_name = issued_book_name
			from issued_status
			where issued_id = @issued_id

	update books
	set status = 'yes'
	where isbn = @isbn

	print 'Thanks for returning your borrowed book' + @book_name
end

---call the procedure:
execute proc_add_return_records 'RS138', 'IS135', 'Good Morning Africa'

---task 17:Give the branch performance report for books issued, books returned, and total revenue
select b.branch_id,
		b.manager_id,
		count(distinct ist.issued_id) as Issued_books,
		count(distinct rs.return_id) as returned_books,
		sum(bk.rental_price) as total_revenue
INTO branch_reports
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

select * from branch_reports

---task 18: create a table of the most active members(with issued books being >1 in the past 2 months)
select * from members

select *
into most_active_members
from members
where member_id in(
		select issued_member_id
		from issued_status
		where issued_date > dateadd(month, -2, GETDATE())
		)

---task  17: Top(3) employees by books issued
select * from employees

SELECT TOP 3
    e.emp_name,
    b.branch_id,
    COUNT(ist.issued_id) AS books_issued
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id	
ORDER BY books_issued DESC;


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
CREATE PROCEDURE issue_book 
    @issued_id VARCHAR(10), 
    @issued_member_id VARCHAR(30), 
    @issued_book_isbn VARCHAR(30), 
    @issued_emp_id VARCHAR(10)
AS
BEGIN
    DECLARE @status VARCHAR(10);

    SELECT @status = status
    FROM books
    WHERE isbn = @issued_book_isbn;

    IF @status = 'yes'
    BEGIN
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (@issued_id, @issued_member_id, GETDATE(), @issued_book_isbn, @issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = @issued_book_isbn;

        PRINT 'Book issued successfully for ISBN: ' + @issued_book_isbn;
    END
    ELSE
    BEGIN
        PRINT 'Book currently unavailable: ' + @issued_book_isbn;
    END
END;

---excecute procedure:
EXEC issue_book 'IS155', 'C108', '978-0-553-29698-2', 'E104';
EXEC issue_book 'IS156', 'C108', '978-0-375-41398-8', 'E104';

