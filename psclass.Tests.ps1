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

Describe "GivenAnObjectWithMethods_AndANonDefaultValue_WhenDeserializing" {
   $testClass = New-PSClass TestObject {
        note -private myVariable 10
        method getVariable {
            return $private.myVariable
        }
        method setVariable {
            param($newValue)
            $private.myVariable = 8
        }
    }
    $toSerialize = $testClass.New();
    $toSerialize.setVariable(8);

    Export-Clixml -InputObject $toSerialize -Path .\object.xml
    $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

    It "ItShouldStillHaveMethods" {
        $deserialized.getVariable().should.be(8)
    }
}