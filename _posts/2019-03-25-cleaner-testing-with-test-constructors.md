---
layout: post
title: "cleaner testing with test constructors"
description: "a superior testing strategy for nested data systems"
date: 2019-03-26
tags: [objectmother, kotlin, testing, lessons]
comments: true
---

Dealing with nested data in tests is a hard problem. 
For systems with deep object graphs (in our case, mortgages), 
the problems are exacerbated by orders of magnitude. 

This blog post has been 3 years in the making, but [after reading a recent post](https://www.jworks.io/easy-testing-with-objectmothers-and-easyrandom/) on [reddit](https://www.reddit.com/r/programming/comments/b59km1/using_objectmothers_to_manage_your_test_data/), I've been prompted to actually sit down and write it all down. 

For the rest of the article we're going to use an example object to show how difficult it can be to deal with nested data.

Here is our original `Applicant` object, including two of the objects that help compose the `Applicant`. These classes originally used Lombok, but I've removed the annotations to make it easier to read. If you care you can pretend that each class has `@Value` and `@Builder` on it.

```java
public class ApplicantValueObject implements Serializable {
    ApplicantAddress currentAddress;
    List<PreviousApplicantAddress> previousAddresses;
    SocialSecurityNumber ssn;
    IndividualTaxIdentificationNumber taxIdentificationNumber;
    LocalDate birthDate;
    int yearsOfSchool;
    RelationshipStatus relationshipStatus;
    PartyAnsweredStatus dependentsProvidedStatus;
    List<Integer> dependents;
    PartyAnsweredStatus veteranProvidedStatus;
    VeteranStatus veteranStatus;
    PartyAnsweredStatus citizenshipProvidedStatus;
    CitizenshipStatus citizenshipStatus;
    String visaType;
    CustomerDetails onlineSalesCustomerDetails;
    boolean mailingAddressDifferentFromCurrentAddress;
}
public class ApplicantAddress implements Serializable {
    PropertyId propertyReference;
    ResidencyBasisType residencyBasisType;
    Money monthlyRent;
    LocalDate start;
    LocalDate end;
}
public class PreviousApplicantAddress implements Serializable {
    PropertyId id;
    ApplicantAddress applicantAddress;
}
```

# traditional

Let's start by talking about the traditional way of doing things. Usually if you need a lot of test data you can do one of two things:

1. Create new test data everywhere you need it.
2. Use a factory to create the test data.

Now, with Java, these really are the two only ways of doing it. You need a factory, or you need to create the test data inline. (You can use that EasyRandom class mentioned in the above articles, but that is only a solution for one case, which I'll talk about later.)

## problems

### create test data in each test

The problem with the first solution is obvious. Using the object above you not only need to come up with data for each test, but you must instantiate every single nested item as well. And you might need to do this hundreds or thousands of times, depending on the size of your test suite.

It's very easy to imagine how convoluted it would be to create a test object for the `Applicant` even if you didn't actually need the data.

### use a factory to create the test data

The problem with the second solution is not so obvious. We started out using test factories at PromonTech and within a year were in agony over the absolute terribleness of the solution.

* They are not flexible. If you need to pass different data for a specific test, well, too bad.
* They cascade test failures through an entire system when changes are made to test data.
* They cascade compile failures through the entire system, _even if unrelated refactors are made_. 

That last one is one of the biggest problems, no matter how well you write your test factories. If you make a change to a nested class, and that class is used in a test factory, then that change will cascade through every single test factory that uses that object in any way. This is completely unsustainable for large systems.  

I'm not going to provide the entire test factory, but here is a snippet of one factory method. As I mentioned before, we used `Lombok` at the time, so we auto-generated builders (with `@Builder`) to help with this. 

```java
//…
public static ApplicantValueObject getApplicantPartyValueObjectWithoutCurrentAddress(UUIDGenerator uuidGenerator) {
    return ApplicantValueObject.builder()
                                .previousAddresses(getPreviousApplicantAddress(uuidGenerator))
                                .ssn(ssn)
                                .taxIdentificationNumber(taxIdentificationNumber)
                                .birthDate(LocalDate.now())
                                .yearsOfSchool(4)
                                .relationshipStatus(RelationshipStatus.MARRIED)
                                .dependents(getDependents())
                                .veteranStatus(VeteranStatus.NA)
                                .citizenshipStatus(CitizenshipStatus.US_CITIZEN)
                                .visaType(visaType)
                                .mailingAddressDifferentFromCurrentAddress(false)
                                .build();
}
//…
```

As you can see, we call several other factory methods, which are also inflexible. 

### EasyRandom

This library looks great. I'll admit I've never used it before. But it's only good in systems where you don't need to do math, or test against external systems, or verify your data in any way. Its _only use is to create a full object_, which is fantastic, but it only covers a small portion of testing. 

If you needed to test some math you would need to generate the object with `EasyRandom`, change several values using setters, and then you could use the object. And what if you need to test against a serialized version in a database? Usually if your object graph is very large, you will write a 'correct' (verified) version to a file,
run your test, and then compare against that object. 

I do think `EasyRandom` sounds like a very good solution if you absolutely 100% cannot use Kotlin at all. But if you can (and you should be able to, I cover that later), then I believe
our method is superior.

# kotlin

At this point in the process, we discovered kotlin and began to use it for other reasons (data objects to get rid of Lombok). We were having issues maintaining thousands of lines of test factory, because if you need to refactor a field, it cascaded changes across the entire system. 

Here is the solution I came up with.

## Test Constructors

Kotlin is great in a lot of ways. One of the things it does right is named parameters. We're going to abuse named parameters to mimic data objects. I've called this concept, `Test Constructors`, because the point is to mimic the actual constructor of the `data class`.

Using the above objects, let's take a subset of them and implement a `Test Constructor` test factory. 

```kotlin
fun applicantValueObject(
    useStaticIds: Boolean = true,
    currentAddress: ApplicantAddress = applicantAddress(useStaticIds),
    previousAddresses: List<PreviousApplicantAddress> = listOf(previousApplicantAddress(useStaticIds)),
    ssn: SocialSecurityNumber = socialSecurityNumber(),
    taxIdentificationNumber: IndividualTaxIdentificationNumber = taxIdentificationNumber(),
    birthDate: LocalDate = BIRTH_DATE,
    yearsOfSchool: Int = YEARS_OF_SCHOOL,
    relationshipStatus: RelationshipStatus = relationshipStatus(),
    dependentsProvidedStatus: PartyAnsweredStatus = dependentsProvidedStatus(),
    dependents: List<Integer> =  dependents(),
    veteranProvidedStatus: PartyAnsweredStatus = veteranProvidedStatus(),
    veteranStatus: VeteranStatus = veteranStatus(),
    citizenshipProvidedStatus: PartyAnsweredStatus = citizenshipProvidedStatus(),
    citizenshipStatus: CitizenshipStatus = citizenshipStatus(),
    visaType: String = VISA_TYPE,
    onlineSalesCustomerDetails: CustomerDetails = onlineSalesCustomerDetails(),
    mailingAddressDifferentFromCurrentAddress: Boolean = mailingAddressDifferentFromCurrentAddress()
) = ApplicantValueObject(
    currentAddress = currentAddress,
    previousAddresses = previousAddresses,
    ssn = ssn,
    taxIdentificationNumber = taxIdentificationNumber,
    birthDate = birthDate,
    yearsOfSchool = yearsOfSchool,
    relationshipStatus = relationshipStatus,
    dependentsProvidedStatus = dependentsProvidedStatus,
    dependents = dependents,
    veteranProvidedStatus = veteranProvidedStatus,
    veteranStatus = veteranStatus,
    citizenshipProvidedStatus = citizenshipProvidedStatus,
    citizenshipStatus = citizenshipStatus,
    visaType = visaType,
    onlineSalesCustomerDetails = onlineSalesCustomerDetails,
    mailingAddressDifferentFromCurrentAddress = mailingAddressDifferentFromCurrentAddress
)
fun previousApplicantAddress(
    useStaticIds: Boolean = true,
    propertyId: PropertyId = propertyId(useStaticIds),
    applicantAddress: ApplicantAddress = applicantAddress(useStaticIds)
) = PreviousApplicantAddress(
    useStaticIds = useStaticIds,
    propertyId = propertyId,
    applicantAddress = applicantAddress
)
fun applicantAddress(
    useStaticIds: Boolean = true,
    propertyReference: PropertyId = propertyId(useStaticIds),
    residencyBasisType: ResidencyBasisType = residencyBasisType(),
    monthlyRent: Money = MONTHLY_RENT,
    start: LocalDate = START_DATE,
    end: LocalDate = END_DATE,
) = ApplicantAddress(
    useStaticIds = useStaticIds,
    propertyReference = propertyReference,
    residencyBasisType = residencyBasisType,
    monthlyRent = monthlyRent,
    start = start,
    end = end
)
```

Now this looks incredibly long, but it's actually simple enough you can generate it. In fact, we have a slack bot to do it for you the first time.

Let's review the `Test Constructor`.

* You can see we make method calls to give each test parameter their
own default value. This allows you to call the test factory method like this:

```kotlin
val sut = applicantValueObject()
```

You receive a fully built object with test data. This is useful when you are testing other parts of the system and don't care about the data in the object; for example when you want to test out an Event Sourcing system's ability to handle commands/events for certain situations. 

* You can see we give some parameters a `Test Constant`. This is useful when you have some consistent data across the application without much logic behind it. If you just care about storing somebody's birthdate or years of school and don't have any logic behind those (usually because you are passing it directly to another system at a later time), then you can just use a `Test Constant`. These constants can be used across your entire test suite (per microservice of course).

* `Test Constants` are also useful when the object is just a regular 'base object', where making a full function for the parameter wouldn't make any sense. That is the case for `ApplicantAddress`'s `start` and `end` dates.

* You can pass any value anywhere in the constructor, just like if it was a Kotlin `data class`. This means if you only need to test that the applicant's previous address had a monthly rent of $500.00, 
then you only need to modify that one thing. 

```kotlin
val sut = applicantValueObject(
            previousApplicantAddress = previousApplicantAddress(
                applicantAddress = applicantAddress(
                    monthlyRent = Money(500.00)
                )))
```

It's incredibly clean and easy to read, especially if you've used named parameters before. 

**_This concept changed our entire testing strategy_**.

* You can pass values through the test object and have them affect nested objects. You can see how we handle this with the `useStaticIds` variable. If you don't pass anything, it will default to providing a 'static' id to each of the objects (essentially making them idempotent). But, if you pass `useStaticIds = false`, then it will change all ids in the test object to be randomly generated.
This is useful when you want to generate a list of many different objects to test some sort of database logic.

* If you refactor `ApplicantValueObject` to _rename_ a field, nothing will break (related to your test factories). Your test factories are using named parameters, but on their own take named parameters. This is extremely powerful, because now the things that actually depend on that rename show up as broken. For example if you are serializing an event and the serialized name breaks, the test that checks that will break, but nothing else. 

* If you refactor `ApplicantValueObject` to _remove_ a field, _only the `Test Constructor` will break_. Stop worrying about breaking unrelated tests and only worry about testing what you are changing.

**__These last concepts are so powerful that we converted every single Java test to Kotlin. We have since moved on to using Kotlin elsewhere, but there is absolutely nothing stopping a team from using Kotlin for tests, but Java everywhere else. In fact, that's exactly what we did for a year and a half.__**

Of course, you could continue to use EasyRandom (as described in the blog posts that inspired my writing this) alongside `Test Constructor`. But you don't need to; the `Test Constructor` strategy has proven to be extremely powerful on its own. We've come to rely on it, and it continues to be a successful and reliable part of our testing strategy.  