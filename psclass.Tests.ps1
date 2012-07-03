$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
. "$here\psclass.ps1"

Describe "GivenAnObjectWithMethods_WhenDeserializing" {
   $testClass = New-PSClass TestObject {
        note -private myVariable 10
        method getVariable {
            return $private.myVariable
        }
    }
    $toSerialize = $testClass.New();
    
    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

        It "ItShouldStillHaveMethods" {
        $deserialized.getVariable().should.be(10)
    }
}

Describe "GivenAnObjectWithPublicNotes_AndANonDefaultValue_WhenDeserializing" {
   $testClass = New-PSClass TestObject {
        note myVariable 10
    }
    $toSerialize = $testClass.New();
    $toSerialize.myVariable = 8;

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

    It "ItShouldStillHaveMethods" {
        $deserialized.myVariable.should.be(8)
    }
}

Describe "GivenAnObjectWithStaticNotes_AndANonDefaultValue_WhenDeserializing" {
   $testClass = New-PSClass TestObject {
        note -static myVariable 10
    }
    $toSerialize = $testClass.New();
    $toSerialize.Class.myVariable = 8;

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

    It "ItShouldStillHaveMethods" {
        $deserialized.Class.myVariable.should.be(8)
    }
}

Describe "GivenAnObjectWithAConstructor_WhenDeserializing" {
   $testClass = New-PSClass TestObject {
        note executedTimes 0
        constructor {
            $this.executedTimes++;
        }
    }
    $toSerialize = $testClass.New();

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

    It "ItShouldDeserializeWithoutExecuting" {
        $deserialized.executedTimes.should.be(1)
    }
}

Describe "GivenAnObjectWithADifferentNameToTestObject_AndPrivateNotes_WhenDeserializing" {
   $testClass = New-PSClass AnotherTestObject {
        note -private executedTimes 0
    }
    $toSerialize = $testClass.New();

    Export-Clixml -InputObject $toSerialize -Path .\object.xml

    It "ItShouldDeserializeWithoutErroring" {
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
    }
}

Describe "GivenAnObjectWithAPropertyWhichIsAPSObject_AndTheBackingFieldIsUpdatedAfterDeserializing_WhenDeserializing" {
    $referencedObject = New-PSClass ReferencedObject {
        note -private myVariable 0
        property MyVariable { $private.myVariable }
        method SetVariable {
            param($val)
            $private.myVariable = $val
        }
    }

    $testClass = New-PSClass TestObject {
        constructor {
            param($refObject)
            $private.referencedObject = $refObject
        }        

        note -private referencedObject
        property ReferencedObject { $private.referencedObject }
    }

    $toSerialize = $testClass.New($referencedObject.New());

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
    $deserialized.ReferencedObject.SetVariable(10)

    It "ShouldReflectTheValue" {
        $deserialized.ReferencedObject.MyVariable.should.be(10)
    }
}

Describe "GivenAnObjectWithACollectionOfObjects_WhenDeserializing" {
    $referencedObject = New-PSClass ReferencedObject {
        note -private myVariable 0
        property MyVariable { $private.myVariable }
        method SetVariable {
            param($val)
            $private.myVariable = $val
        }
    }

    $testClass = New-PSClass TestObject {
        constructor {
            param($refObjects)
            $private.referencedObjects = $refObjects
        }        

        note -private referencedObjects @()
        property ReferencedObjects { $private.referencedObjects }
    }

    $toSerialize = $testClass.New(@($referencedObject.New(), $referencedObject.New()));

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
    $deserialized.ReferencedObjects[0].SetVariable(10)
    $deserialized.ReferencedObjects[1].SetVariable(20)

    It "TheObjectsInTheCollectionShouldBeDeserialized" {
        $deserialized.ReferencedObjects[0].MyVariable.should.be(10)
        $deserialized.ReferencedObjects[1].MyVariable.should.be(20)
    }
}