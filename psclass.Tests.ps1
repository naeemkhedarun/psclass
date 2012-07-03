$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
. "$here\psclass.ps1"

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