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