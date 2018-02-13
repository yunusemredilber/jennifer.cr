require "../spec_helper"

describe Jennifer::Model::Base do
  describe "#changed?" do
    it "returns true if at list one field was changed" do
      c = Factory.build_contact
      c.name = "new name"
      c.changed?.should be_true
    end

    it "returns false if no one field was changed" do
      Factory.build_contact.changed?.should be_false
    end
  end

  describe "::primary" do
    it "return criteria with primary key" do
      c = Passport.primary
      match_fields(c, table: "passports", field: "enn")
    end
  end

  describe "::primary_field_name" do
    it "returns name of custom primary field" do
      Passport.primary_field_name.should eq("enn")
    end

    it "returns name of default primary field name" do
      Contact.primary_field_name.should eq("id")
    end
  end

  describe "::primary_field_type" do
    it "returns type of custom primary field" do
      Passport.primary_field_type.should eq(String?)
    end

    it "returns type of default primary field name" do
      Contact.primary_field_type.should eq(Int32?)
    end
  end

  describe "#init_primary_field" do
    it "sets primary field" do
      c = Factory.build_contact
      c.init_primary_field(1)
      c.primary.should eq(1)
    end

    it "raises error if it is set" do
      c = Factory.build_contact
      c.init_primary_field(1)
      expect_raises(Exception, "Primary field is already initialized") do
        c.init_primary_field(1)
      end
    end
  end

  describe "#new_record?" do
    it "returns true if mrimary field nil" do
      Factory.build_contact.new_record?.should be_true
    end

    it "returns false if primary field is not nil" do
      Factory.create_contact.new_record?.should be_false
    end
  end

  describe "::create" do
    it "doesn't raise exception if object is invalid" do
      country = Country.create
      country.should_not be_valid
      country.id.should be_nil
    end

    context "without arguments" do
      it "builds new object without any exception" do
        c = ContactWithNotStrictMapping.create
        c.id.should_not be_nil
        c.name.should be_nil
      end
    end

    context "from hash" do
      context "with string keys" do
        it "properly creates object" do
          contact = Contact.create({"name" => "Deepthi", "age" => 18, "gender" => "female"})
          contact.id.should_not be_nil
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end

      context "with symbol keys" do
        it "properly creates object" do
          contact = Contact.create({:name => "Deepthi", :age => 18, :gender => "female"})
          contact.id.should_not be_nil
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end
    end

    context "from named tuple" do
      it "properly creates object" do
        contact = Contact.create({name: "Deepthi", age: 18, gender: "female"})
        contact.id.should_not be_nil
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end

      it "allows splatted named tuple as well" do
        contact = Contact.create(name: "Deepthi", age: 18, gender: "female")
        contact.id.should_not be_nil
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end
    end
  end

  describe "::create!" do
    it "raises exception if object is invalid" do
      expect_raises(Jennifer::RecordInvalid) do
        Country.create!
      end
    end

    context "without arguments" do
      it "builds new object without any exception" do
        c = ContactWithNotStrictMapping.create!
        c.id.should_not be_nil
        c.name.should be_nil
      end
    end

    context "from hash" do
      context "with string keys" do
        it "properly creates object" do
          contact = Contact.create!({"name" => "Deepthi", "age" => 18, "gender" => "female"})
          contact.id.should_not be_nil
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end

      context "with symbol keys" do
        it "properly creates object" do
          contact = Contact.create!({:name => "Deepthi", :age => 18, :gender => "female"})
          contact.id.should_not be_nil
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end
    end

    context "from named tuple" do
      it "properly creates object" do
        contact = Contact.create!({name: "Deepthi", age: 18, gender: "female"})
        contact.id.should_not be_nil
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end

      it "allows splatted named tuple as well" do
        contact = Contact.create!(name: "Deepthi", age: 18, gender: "female")
        contact.id.should_not be_nil
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end
    end
  end

  describe "::build" do
    context "without arguments" do
      it "builds new object without any exception" do
        p = Passport.build
        p.enn.nil?.should be_true
        p.contact_id.nil?.should be_true
      end
    end

    context "from hash" do
      context "with string keys" do
        it "properly creates object" do
          contact = Contact.build({"name" => "Deepthi", "age" => 18, "gender" => "female"})
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end

      context "with symbol keys" do
        it "properly creates object" do
          contact = Contact.build({:name => "Deepthi", :age => 18, :gender => "female"})
          match_fields(contact, name: "Deepthi", age: 18, gender: "female")
        end
      end
    end

    context "from named tuple" do
      it "properly creates object" do
        contact = Contact.build({name: "Deepthi", age: 18, gender: "female"})
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end

      it "allows splatted named tuple as well" do
        contact = Contact.build(name: "Deepthi", age: 18, gender: "female")
        match_fields(contact, name: "Deepthi", age: 18, gender: "female")
      end
    end
  end

  describe "#save" do
    it "saves new object to db" do
      count = Contact.all.count
      contact = Factory.build_contact
      contact.save
      Contact.all.count.should eq(count + 1)
    end

    context "updates existing object in db" do
      it "stores changed fields to db" do
        c = Factory.create_contact
        c.name = "new name"
        c.save
        Contact.find!(c.id).name.should eq("new name")
      end

      it "returns true if record was saved" do
        c = Factory.create_contact
        c.id.nil?.should be_false
        c.name = "new name"
        c.save.should be_true
      end

      it "returns false if record wasn't saved" do
        Factory.create_contact.save.should be_false
      end

      it "calls after_save_callback" do
        c = Factory.create_contact
        c.name = "new name"
        c.save
        c.name_changed?.should be_false
      end
    end

    context "brakes unique index" do
      it "raises exception" do
        void_transaction do
          Factory.create_address(street: "st. 2")
          expect_raises(Jennifer::BaseException) do
            Factory.create_address(street: "st. 2")
          end
        end
      end
    end
  end

  describe "::table_name" do
    it "loads from class name automatically" do
      Contact.table_name.should eq("contacts")
    end

    it "returns specified name" do
      ContactWithNotAllFields.table_name.should eq("contacts")
    end
  end

  describe "::c" do
    it "creates criteria with given name" do
      c = Contact.c("some_field")
      c.is_a?(Jennifer::QueryBuilder::Criteria)
      c.field.should eq("some_field")
      c.table.should eq("contacts")
      c.relation.should be_nil
    end

    it "creates criteria with given name and relation" do
      c = Contact.c("some_field", "some_relation")
      c.is_a?(Jennifer::QueryBuilder::Criteria)
      match_fields(c, field: "some_field", table: "contacts", relation: "some_relation")
    end
  end

  describe "%scope" do
    context "with block" do
      it "executes in query context" do
        ::Jennifer::Adapter.adapter.sql_generator.select(Contact.all.ordered).should match(/ORDER BY contacts\.name ASC/)
      end

      context "without arguemnt" do
        it "is accessible from query object" do
          Contact.all.main.as_sql.should match(/contacts\.age >/)
        end
      end

      context "with argument" do
        it "is accessible from query object" do
          Contact.all.older(12).as_sql.should match(/contacts\.age >=/)
        end
      end

      context "same names" do
        it "is accessible from query object" do
          Address.all.main.as_sql.should match(/addresses\.main/)
          Contact.all.main.as_sql.should match(/contacts\.age >/)
        end
      end

      it "is chainable" do
        c1 = Factory.create_contact(age: 15)
        c2 = Factory.create_contact(age: 15)
        c3 = Factory.create_contact(age: 13)
        Factory.create_address(contact_id: c1.id, main: true)
        Factory.create_address(contact_id: c2.id, main: false)
        Factory.create_address(contact_id: c3.id, main: true)
        Contact.all.with_main_address.older(14).count.should eq(1)
      end
    end

    context "with query object class" do
      it "executes in class context" do
        ::Jennifer::Adapter.adapter.sql_generator.select(Contact.johny).should match(/name =/)
      end

      context "without arguemnt" do
        it "is accessible from query object" do
          Contact.johny.as_sql.should match(/contacts\.name =/)
        end
      end

      context "with argument" do
        it "is accessible from query object" do
          Contact.by_age(12).as_sql.should match(/contacts\.age =/)
        end
      end

      it "is chainable" do
        c1 = Factory.create_contact(name: "Johny")
        c3 = Factory.create_contact
        Factory.create_address(contact_id: c1.id, main: true)
        Factory.create_address(contact_id: c3.id, main: true)
        Contact.with_main_address.johny.count.should eq(1)
      end
    end
  end

  describe "::relations" do
    it "returns hash of relation objects" do
      rels = Contact.relations
      rels.is_a?(Hash).should be_true
      rels.empty?.should be_false
    end
  end

  describe "#destroy" do
    it "deletes from db" do
      contact = Factory.create_contact
      contact.destroy
      Contact.all.exists?.should be_false
    end

    it "invokes destroy callbacks" do
      address = Factory.create_address
      count = Address.destroy_counter
      address.destroy
      (Address.destroy_counter - count).should eq(1)
    end
  end

  describe "#delete" do
    it "deletes from db by given ids" do
      contact = Factory.create_contact
      contact.delete
      Contact.all.exists?.should be_false
    end

    it "doen't invoke destroy callbacks" do
      address = Factory.create_address
      count = Address.destroy_counter
      address.delete
      Address.destroy_counter.should eq(count)
    end
  end

  describe "#lock!" do
    it "lock current record" do
      Factory.create_contact.lock!
      query_log.last.should match(/FOR UPDATE/)
    end

    it "raises exception if transaction is not started" do
      void_transaction do
        Factory.create_contact.lock!
      end
    end
  end

  describe "#with_lock" do
    it "starts transaction" do
      void_transaction do
        expect_raises(DivisionByZero) do
          Factory.create_contact.with_lock do
            Factory.create_contact
            Contact.all.count.should eq(2)
            1 / 0
          end
        end
        Contact.all.count.should eq(1)
      end
    end

    it "locks for update" do
      Factory.create_contact.with_lock do
        query_log.last.should match(/FOR UPDATE/)
      end
    end
  end

  describe "::transaction" do
    it "allow to start transaction" do
      void_transaction do
        expect_raises(DivisionByZero) do
          Contact.transaction do
            Factory.create_contact
            1 / 0
          end
        end
        Contact.all.count.should eq(0)
      end
    end
  end

  describe "::where" do
    it "returns query" do
      res = Contact.where { _id == 1 }
      res.should be_a(::Jennifer::QueryBuilder::ModelQuery(Contact))
    end
  end

  describe "::all" do
    it "returns empty query" do
      Contact.all.empty?.should be_true
    end
  end

  describe "::destroy" do
    it "deletes from db by given ids" do
      c = [] of Int32?
      3.times { |i| c << Factory.create_contact.id }
      Contact.destroy(c[0..1])
      Contact.all.count.should eq(1)
    end

    it "invokes destroy callbacks" do
      address = Factory.create_address
      count = Address.destroy_counter
      Address.destroy([address.id])
      (Address.destroy_counter - count).should eq(1)
    end
  end

  describe "::delete" do
    it "deletes from db by given ids" do
      c = [] of Int32?
      3.times { |i| c << Factory.create_contact.id }
      Contact.delete(c[0..1])
      Contact.all.count.should eq(1)
    end

    it "doen't invoke destroy callbacks" do
      address = Factory.create_address
      count = Address.destroy_counter
      Address.delete([address.id])
      Address.destroy_counter.should eq(count)
    end
  end

  describe "::models" do
    it "returns all model classes" do
      models = Jennifer::Model::Base.models
      models.is_a?(Array(Jennifer::Model::Base.class)).should be_true
      # I tired from modifing this each time new model is added
      (models.size > 6).should be_true
    end
  end

  describe "::import" do
    context "with autoincrementable primary key" do
      it "imports objects" do
        void_transaction do
          objects = Factory.build_contact(2)
          Contact.all.count.should eq(0)
          Contact.import(objects)
          Contact.all.count.should eq(2)
        end
      end

      it "sets ids to all given objects" do
        void_transaction do
          objects = Factory.build_contact(2)
          new_collection = Contact.import(objects)
          objects.should eq(new_collection)
          objects[0].id.nil?.should be_false
          objects[1].id.nil?.should be_false
        end
      end
    end

    context "with custom primary key" do
      it "imports objects" do
        void_transaction do
          objects = [Factory.build_address(enn: "qwer"), Factory.build_address(enn: "zxcc")]
          Address.import(objects)
          Address.all.count.should eq(2)
        end
      end
    end
  end
end
