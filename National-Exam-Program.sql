
---TO test the system compile sequences at first then create table individually miyolebit DD and date variable last.
--Then compile package registration and then its body then exam_info  and its body and finaly use my tests and views.

--sequence to number the exam cards.
create sequence exam_cards
increment by 1     
start with 0
nomaxvalue
minvalue 0
nocycle
nocache;
--sequence to number the exam places.
create sequence exam_place_seq  
increment by 1
start with 1
nomaxvalue
minvalue 1
nocycle 
nocache;
--sequence to number the subjects
create sequence subject_seq
increment by 1
start with 0
nomaxvalue
minvalue 0
nocycle 
nocache;
--sequence to number universities.
create sequence university_seq
increment by 1
start with 0
nomaxvalue
minvalue 0
nocycle
nocache;
--sequence to number faculties.
create sequence faculty_seq
increment by 1
start with 0
nomaxvalue
minvalue 0
nocycle
nocache;

--Package which saves information about the starting date of national exam and next available exam date.
create or replace package dateVariable is
 start_date date := TO_DATE('01-06-2021','DD-MM-YYYY');
 next_available_date date :=TO_DATE('01-06-2021','DD-MM-YYYY');
end; 

--Table to store information about the exam places.
create table exam_places(
exam_place_id number(11) primary key,
exam_place_address varchar2(100) constraint ex_place_unk unique
)
--Table creation which contains information about the students.
create Table students(
 student_id number(11) constraint prime primary key,
 pin varchar2(100) constraint uni unique,
 first_name varchar2(100) constraint stud_first_name not null,
 last_name varchar2(100) constraint stud_last_name NOT NULL,
 exam_place_id number(8) ,
 constraint exam_plac_fk foreign key(exam_place_id) references exam_places(exam_place_id),
 email varchar(100) constraint unk unique
)
--Table to store students previous information.
create Table students_log(
   student_id number(11),
   pin varchar2(100),
   first_name varchar2(100),
   last_name varchar2(100),
   exam_place_id number(8),
   change_date date,
   constraint stud_id_fk foreign key (student_id) references students(student_id)
)
--Table of universities which contains id and university naem.
create table universities(
 university_name varchar2(100) constraint univ_unk unique,
 university_id number(11) constraint univ_univ_id_pk primary key
)
--Table of faculties which has faculty_id primary key and university_id as foreign key.
create table faculties(
  faculty_id number(11) constraint fac_id_pk primary key,
  faculty_name varchar2(100),
  university_id number(11),
  constraint faculty_fk foreign key(university_id) references universities(university_id) 
)
--Table of subjects which gave subject_id and subject_name.
create table subjects(
 subject_id number(11) constraint subj_unk unique,
 subj_name varchar2(100),
 start_date date constraint marto unique
)
--Table which have information about the student subjects.
create table students_subjects(
       student_id number(11),
       subject_id number(11),
       constraint stud_subj_stud_fk foreign key (student_id) references students (student_id),
       constraint stud_subj_subj_fk foreign key (subject_id) references subjects (subject_id),
       constraint unikaluri primary key (student_id,subject_id),
       points number(3)
)
--Table which have the information about the faculties of the student and their priorities.
create table student_faculties(
       student_id number(11),
       faculty_id number(11),
       faculty_priority number(6) constraint max_faculty check (faculty_priority < 21 and faculty_priority>0),
       constraint stud_facu_stud_id_fk foreign key (student_id) references students(student_id),
       constraint stud_facu_facu_id_fk foreign key (faculty_id) references faculties(faculty_id),
       constraint stud_facu_pk primary key (student_id,faculty_id)
)
--Table to save information before the changes.
create table student_changes(
  student_id number(11),
  changed_faculties varchar2(300),
  changed_subjects varchar2(300),
  change_date date
)
--Table to print exam cards and save every information about them.
create table exam_card_table(
exam_card_id number(11) constraint exam_crd_not_null not null,
student_id number(11), 
first_name varchar2(30),
last_name varchar2(30),
exam_address varchar(100),
subject_id number(11) ,
subject_name varchar2(30),
exam_date date,
room_number number(11),
constraint unikalurebi unique(student_id,subject_id),
constraint  stud_fk foreign key(student_id) references students(student_id),
constraint sub_fk foreign key(subject_id) references subjects(subject_id)
)





--Registration package.
create or replace package registration
is
procedure add_student(
stud_id            students.student_id % type,
student_pin        students.pin % type,
student_name       students.first_name % type,
student_last_name  students.last_name % type,
student_mail       students.email % type
);

procedure choose_subject(
 v_stud_id   students.student_id%type,
 v_sub_id    subjects.subject_id% type
);

procedure choose_place(
v_stud_id students.student_id%type,
v_exam_id students.exam_place_id%type
);

procedure choose_faculty(
v_stud_id student_faculties.student_id%type,
v_fac_id student_faculties.faculty_id%type
);

procedure delete_subject(
v_stud_id students.student_id%type,
v_sub_id subjects.subject_id%type
);

procedure delete_faculty(
v_stud_id  students.student_id%type,
v_fac_id   faculties.faculty_id%type
);

procedure change_first_name(
v_stud_id students.student_id%type,
v_first_name students.first_name%type
);

procedure change_last_name(
v_stud_id students.student_id%type,
v_last_name students.last_name%type
);

procedure change_pin(
v_stud_id students.student_id%type,
v_pin students.pin%type
);

procedure change_exam_place(
v_stud_id students.student_id%type,
v_exam_place students.exam_place_id%type
);
end registration;

/




--Package implementation.
create or replace package body  registration is

--Procedure to add student to the base
procedure add_student(
stud_id            students.student_id % type,
student_pin        students.pin % type,
student_name       students.first_name % type,
student_last_name  students.last_name % type,
student_mail       students.email % type
)is
 unique_exc exception;
 null_val exception;
 pragma exception_init(null_val, -01400);
 pragma exception_init(unique_exc, -00001);
Begin  
  insert into students (student_id, pin,first_name,last_name,email)
  values(stud_id,student_pin,student_name,student_last_name,student_mail);
  exception
    when unique_exc then
      dbms_output.put_line('you tried to insert same value second time.');
    when null_val then
      dbms_output.put_line('You tried to insert null value in the column of the table where it is banned.');
    when others then
      dbms_output.put_line('Something unknown has happened.');  
end add_student;
--This procedure enables you to choose subject which is not in your list yet.
 procedure choose_subject(
 v_stud_id   students.student_id%type,
 v_sub_id    subjects.subject_id% type
)is
cursor stud_sub_cursor is
select subject_id
from students_subjects
where student_id=v_stud_id;
sagnebi varchar2(300);
sub_id subjects.subject_id%type; 
already_reg exception;
pragma exception_init(already_reg, -00001);
already_late exception;
pragma exception_init(already_late,-20003);
begin 
  insert into students_subjects(student_id, subject_id)
  values (v_stud_id,v_sub_id);
  open stud_sub_cursor;
  loop 
    fetch stud_sub_cursor into sub_id;
    exit when stud_sub_cursor%notfound;
    sagnebi:=sagnebi || to_char(sub_id)||',';
    end loop;
  close stud_sub_cursor;  
  insert into student_changes(student_id,changed_subjects,change_date)  
  values (v_stud_id,sagnebi,sysdate);
  exception
    when already_reg then
      dbms_output.put_line('You are already registered on the subject');
    when others then
      dbms_output.put_line('Something happened');  
end choose_subject;

--Procedure to choose the exam place.
procedure choose_place(
v_stud_id students.student_id%type,
v_exam_id students.exam_place_id%type
)
is
parent_key exception;
pragma exception_init(parent_key,-02291);
begin 
  update students
  set exam_place_id=v_exam_id
  where student_id=v_stud_id;
  exception
    when no_data_found then
    dbms_output.put_line('There is no such data.');
    when parent_key then
      dbms_output.put_line('There is no such exam place.');
  end choose_place;
 
--This procedure enable us to choose faculties if the we haven't reached the limit yet.
procedure choose_faculty(
v_stud_id student_faculties.student_id%type,
v_fac_id student_faculties.faculty_id%type
)
is
stud_num integer;
CURSOR c_stud_cursor is 
select faculty_id
from  student_faculties
where student_id=v_stud_id;
faculty_limit exception;
already_late exception;
pragma exception_init(already_late,-20002);
pragma exception_init(faculty_limit,-20001);
already_exist exception;
pragma exception_init(already_exist,-00001);
previous_faculties varchar2(300);
prev_fac_id student_faculties.faculty_id%type;
not_existed exception;
pragma exception_init(not_existed, -02291);
begin
  open c_stud_cursor;
  stud_num := c_stud_cursor%rowcount;
  if c_stud_cursor%ROWCOUNT >19 then
    raise faculty_limit;
  elsif dateVariable.start_date-sysdate < 10 then
    raise already_late;  
  end if;  
  loop
    fetch c_stud_cursor into prev_fac_id;
    stud_num:=stud_num+1;
    previous_faculties:=previous_faculties || to_char(prev_fac_id) ||',';
    exit when c_stud_cursor%notfound;
    end loop;
  insert into student_faculties(student_id,faculty_id,faculty_priority)
  values (v_stud_id,v_fac_id,stud_num+1);
  if stud_num > 1 then
    insert into student_changes(student_id,changed_faculties,changed_subjects,change_date)
    values(v_stud_id,previous_faculties,' ',sysdate);
    end if;  
  close c_stud_cursor;
  exception
    when faculty_limit then
      dbms_output.put_line('You have already reached the limit of faculties.');
    when already_late then 
      dbms_output.put_line('You can not choose any faculty any more because change date expired.');
    when already_exist then
      dbms_output.put_line('You have already chosen this faculty.');
    when not_existed then
      dbms_output.put_line('There is no such faculty.');      
  end choose_faculty; 

--Subject deletion procedure.
procedure delete_subject(
v_stud_id students.student_id%type,
v_sub_id subjects.subject_id%type
)is
cursor stud_sub_cursor is
select subject_id
from students_subjects
where student_id=v_stud_id;
sagnebi varchar2(300); 
sub_id subjects.subject_id%type; 
begin
  open stud_sub_cursor;
  loop 
    fetch stud_sub_cursor into sub_id;
    exit when stud_sub_cursor%notfound;
    sagnebi:=sagnebi || to_char(sub_id)||',';
    end loop;
  close stud_sub_cursor; 
  delete 
  from students_subjects
  where students_subjects.student_id=v_stud_id and students_subjects.subject_id=v_sub_id;
  insert into student_changes(student_id,changed_subjects,change_date)  
  values (v_stud_id,sagnebi,sysdate); 
end delete_subject;

--Faculty deletion procedure.
procedure delete_faculty(
v_stud_id  students.student_id%type,
v_fac_id   faculties.faculty_id%type
)is
shegvxvda boolean :=false;
previous_faculties varchar2(300);
prev_fac_id faculties.faculty_id%type;
prev_fac_prio student_faculties.faculty_priority%type;
CURSOR c_stud_cursor is 
select faculty_id,faculty_priority
from  student_faculties
where student_id=v_stud_id;
begin 
  open c_stud_cursor;
  loop
    exit when c_stud_cursor%notfound;
    fetch c_stud_cursor into prev_fac_id,prev_fac_prio;
    previous_faculties:=previous_faculties || to_char(prev_fac_id) ||',';
    if prev_fac_id = v_fac_id then
      shegvxvda := true;
      continue;
    end if;
    if shegvxvda = false then
      continue;
      end if;
    update student_faculties
    set faculty_priority=prev_fac_prio-1
    where student_faculties.student_id=v_stud_id and student_faculties.faculty_priority=prev_fac_prio;  
    end loop;
  close c_stud_cursor; 
  delete 
  from student_faculties
  where student_faculties.student_id=v_stud_id and student_faculties.faculty_id=v_fac_id;
  insert into student_changes(student_id,changed_faculties,change_date)
  values (v_stud_id,previous_faculties,sysdate);
  end delete_faculty;
--first_name change operation.
procedure change_first_name(
v_stud_id students.student_id%type,
v_first_name students.first_name%type
)is
no_data exception;
pragma exception_init(no_data,-00001);
already_late exception;
pragma exception_init(already_late,-20012);
begin 
    if Datevariable.start_date - sysdate < 10 then
      raise already_late;
    end if;
    insert into students_log (student_id,first_name,change_date)
    values(v_stud_id,v_first_name,sysdate);
    update students 
    set first_name = v_first_name
    where v_stud_id = student_id;
    exception
      when already_late then
        dbms_output.put_line('Now it is already late to change your first name');
      when no_data then
        dbms_output.put_line('There is no such student');
      when others then 
        dbms_output.put_line('Something unknown happened');               
end change_first_name;
--last_name change operation.
procedure change_last_name(
v_stud_id students.student_id%type,
v_last_name students.last_name%type
)is
no_data exception;
pragma exception_init(no_data,-00001);
already_late exception;
pragma exception_init(already_late,-20012);
begin 
    if Datevariable.start_date - sysdate < 10 then
      raise already_late;
    end if;
    insert into students_log (student_id,last_name,change_date)
    values(v_stud_id,v_last_name,sysdate);
    update students 
    set last_name = v_last_name
    where v_stud_id = student_id;
    exception
      when already_late then
        dbms_output.put_line('Now it is already late to change your first name');
      when no_data then
        dbms_output.put_line('There is no such student');
      when others then 
        dbms_output.put_line('Something unknown happened');               
end change_last_name;

--Pin change procedure.
procedure change_pin(
v_stud_id students.student_id%type,
v_pin students.pin%type
)is
already_late exception;
no_data exception;
pragma exception_init(already_late,-20005);
pragma exception_init(no_data,-00001);
begin
  if datevariable.start_date - sysdate < 10 then
    raise already_late;
    end if;
    insert into students_log(student_id,pin,change_date)
    values (v_stud_id,v_pin,sysdate);
    update students
    set pin = v_pin
    where student_id = v_stud_id;
    exception 
      when already_late then
        dbms_output.put_line('Change date has already expired you can change your pin');
      when no_data then
        dbms_output.put_line('There is no such student');
      when others then
        dbms_output.put_line('Something unknown happened');    
  end change_pin;
  
--exam_place change procedure.
procedure change_exam_place(
v_stud_id students.student_id%type,
v_exam_place students.exam_place_id%type
)is
already_late exception;
no_data exception;
pragma exception_init(already_late,-20005);
pragma exception_init(no_data,-00001);
begin
  if datevariable.start_date - sysdate < 10 then
    raise already_late;
    end if;
    insert into students_log(student_id,exam_place_id,change_date)
    values (v_stud_id,v_exam_place,sysdate);
    update students
    set exam_place_id = v_exam_place
    where student_id = v_stud_id;
    exception 
      when already_late then
        dbms_output.put_line('Change date has already expired you can change your pin');
      when no_data then
        dbms_output.put_line('There is no such student');
      when others then
        dbms_output.put_line('Something unknown happened');    
  end change_exam_place;
end registration;
/


--Package functional which fills the tables of faculties,subjects and universities.
create or replace package exam_info is

procedure add_subject(
       sub_name subjects.subj_name % type
);
procedure add_university(
 univ_name universities.university_name %type
); 
procedure add_faculty(
v_fac_name faculties.faculty_name%type,
v_uni_id faculties.university_id%type
);

procedure randomize_points;

procedure add_exam_place(
v_exam_place exam_places.exam_place_address%type
);


procedure create_exam_cards(
 v_student_id students.student_id%type
);

procedure allocateRooms;

procedure fill_exam_card_table;

end exam_info;
  


--Exam_info implementation.
create or replace package body exam_info is

--Procedure to add subject in the base.
procedure add_subject(
       sub_name subjects.subj_name % type
) is
unique_excep exception;
null_exp exception;
pragma exception_init(unique_excep, -00001);
pragma exception_init(null_exp,-01400);
begin 
  --dbms_output.put_line(to_char(subject_seq.nextval) ||'afkfa');
  dateVariable.next_available_date := dateVariable.next_available_date+1;
  insert into subjects (subject_id, subj_name,start_date)
  values (subject_seq.nextval,sub_name,dateVariable.next_available_date);
  exception
    when unique_excep then
      dbms_output.put_line('You tried to insert the same subject second time.');
    when null_exp then
      dbms_output.put_line('You tried to insert null value in the table.');  
    when others then
      dbms_output.put_line('You tried illegal formats.');
end add_subject;

--Procedure to add university in the base.
procedure add_university(
 univ_name universities.university_name %type
) is 
unique_exp exception;
null_exp exception;
pragma exception_init(unique_exp,-00001);
pragma exception_init(null_exp,-01400);
begin 
  insert into universities(university_name, university_id)
  values (univ_name,university_seq.nextval);
  exception 
    when null_exp then
      dbms_output.put_line('You tried to insert null value in the table.');
    when unique_exp then
      dbms_output.put_line('You tried to insert same university second time.');
   
end add_university;
--Faculty addition procedure.
procedure add_faculty(
v_fac_name faculties.faculty_name%type,
v_uni_id faculties.university_id%type
)is
unikaluri exception;
pragma exception_init(unikaluri, -00001);
begin 
  insert into faculties(faculty_id,faculty_name,university_id)  
  values (faculty_seq.nextval,v_fac_name,v_uni_id);
  exception
    when unikaluri then
      dbms_output.put_line('You tried to insert same faculty twice');
    when others then
      dbms_output.put_line('Some unknown error happened');
end add_faculty;

--This procedure randomizes points. 
procedure randomize_points is
begin 
 update 
 students_subjects
 set students_subjects.points=dbms_random.value(20,100);
 end; 
--Procedure which enables us to add exam place.
procedure add_exam_place(
v_exam_place exam_places.exam_place_address%type
)is
already_exist exception;
pragma exception_init(already_exist, -00001); 
begin 
  insert into exam_places(exam_place_id, exam_place_address)
  values(exam_place_seq.nextval,v_exam_place);
  exception
    when already_exist then
      dbms_output.put_line('already existed such address');
  end add_exam_place;

--Procedure to fill exam_cards.
procedure create_exam_cards(
 v_student_id students.student_id%type
)is
unika exception;
pragma exception_init(unika,-00001);
cursor subject_cursor is
select s.subj_name,s.subject_id,s.start_date
from subjects s
join students_subjects sb on  s.subject_id=sb.subject_id
where sb.student_id=v_student_id;
v_card_id number(8);
v_exam_place exam_places.exam_place_address%type;
v_student_row students%rowtype;
begin 
  select * into v_student_row from students where student_id=v_student_id;
  v_card_id:=exam_cards.nextval;
  select exam_place_address into v_exam_place from exam_places 
  where exam_places.exam_place_id=v_student_row.exam_place_id;
  for v_subject_rec in subject_cursor loop 
    insert into exam_card_table(exam_card_id,student_id,first_name,last_name,exam_address,subject_id,
                                subject_name,exam_date)
    values(v_card_id,v_student_row.student_id,v_student_row.first_name,v_student_row.last_name,v_exam_place,
    v_subject_rec.subject_id,v_subject_rec.subj_name,v_subject_rec.start_date);
    end loop;
    exception
      when no_data_found then
        dbms_output.put_line('You tried illegal formats');
      when unika then
        dbms_output.put_line('You tried to insert same row');
  end create_exam_cards;
--Procedure to allocate rooms for students.
procedure allocateRooms
is 
cursor exam_cards_cursor is 
select * 
from exam_card_table 
order by exam_address,subject_id;
v_cur_room number:=1;
v_cur_sub number:=0;
v_cur_stud_num number:=0;
v_cur_exam_address varchar2(100):='';
begin 
  for card_record in exam_cards_cursor loop
    if not v_cur_sub=card_record.subject_id then
      v_cur_sub :=card_record.subject_id;
      v_cur_room :=1;
      v_cur_stud_num :=0;
      end if;
    if not v_cur_exam_address=card_record.exam_address then
     v_cur_exam_address:=card_record.exam_address;
     v_cur_room :=1;
     v_cur_stud_num :=0;
     end if;
     update exam_card_table
     set room_number=v_cur_room
     where exam_card_id=card_record.exam_card_id and subject_id=v_cur_sub;
     v_cur_stud_num :=v_cur_stud_num +1;
     if v_cur_stud_num = 30 then
       v_cur_room := v_cur_room +1;
       v_cur_stud_num :=0;
       end if;
   end loop;   
   exception
     when others then
       dbms_output.put_line('Something has happened');
  end allocateRooms;
--This procedure fills exam_cards for every participant.
procedure fill_exam_card_table is
cursor student_cursor is
select student_id
from students;
begin 
  for cur_student in student_cursor loop
    create_exam_cards(cur_student.student_id);
   end loop;
   allocateRooms;
   exception 
     when others then
       dbms_output.put_line('Something unknown happened');
end fill_exam_card_table;

end exam_info;
/

--View creation which enables us to see the information of the students.
create or replace view results as
select stud.student_id,sub.subj_name,stud.points
from students_subjects stud
join subjects sub on sub.subject_id=stud.subject_id
order by  (select avg(points)
                  from students_subjects s
                  where s.student_id=stud.student_id)desc,
sub.subj_name asc 
/
--View creation which shows an information of university rankings.
create or replace view ranking as
select uni.university_name
from student_faculties stud
join faculties fac on fac.faculty_id=stud.faculty_id
right join universities uni on uni.university_id=fac.university_id
group by uni.university_name 
order by count(*) desc;
--To test the system.
begin 
 exam_info.add_subject('Mathematics');
 exam_info.add_subject('GEORGIAN');
 exam_info.add_subject('Physics'); 
 exam_info.add_university('Free University of Tbilisi');
 exam_info.add_university('Tbilisi State University');
 exam_info.add_university('Kutaisi International University');
 exam_info.add_faculty('MACSE',1);
 exam_info.add_faculty('VAADS',1);
 exam_info.add_faculty('ENGINEERING',1);
 exam_info.add_exam_place('KOMAROVI');
 exam_info.add_exam_place('NAEC');
 exam_info.add_exam_place('VEKUA');
 registration.add_student(888,12341,'Nika','Kvitsiani','NKvits');
 registration.add_student(999,54321,'David','Tskhondia','DTskho');
 registration.add_student(777,21341,'Luka','Macharashvili','LMach');
 registration.choose_place(777,1);
 registration.choose_place(888,2);
 registration.choose_place(999,3);
 --Exception trigger operation.
 registration.choose_place(102,4);
 
 registration.choose_subject(777,1);
 registration.choose_subject(888,1);
 registration.choose_subject(999,1);
 registration.choose_subject(777,2);
 --At this moment in the previous information I will save subject_before change.
 registration.delete_subject(777,1);
 registration.choose_faculty(777,1);
 registration.choose_faculty(777,2);
 registration.choose_faculty(888,1);
 registration.choose_faculty(999,3);
 registration.change_first_name(888,'NICK');
 registration.change_last_name(777,'MACHO');
 exam_info.fill_exam_card_table;
 exam_info.randomize_points;
end;
--Delete everything.
/*
  drop table students_log;
  drop table exam_card_table;
  drop table student_changes;
  drop table student_faculties;
  drop table students_subjects;
  drop table subjects;
  drop table faculties;
  drop table universities;
  drop table students;
  drop table exam_places;
  drop sequence faculty_seq;
  drop sequence university_seq;
  drop sequence subject_seq;
  drop sequence exam_cards;
  drop sequence exam_place_seq;
 */
