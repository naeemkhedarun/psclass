
$AnimalClass = New-PSClass Animal `
{

  note -static ObjectCount 0
  method -static DisplayObjectCount {
    "$($this.ClassName) has $($this.ObjectCount) instances"
  }

  note -private Name
  note -private Legs

  constructor {
    param ($name,$legs)
    $private.Name = $name
    $private.Legs = $legs
    
    $AnimalClass.ObjectCount += 1
  }
  
  property Name {
    $private.Name
  } -set {
    param($newName)
    Write-Host "Renaming $($this.Class.ClassName) '$($private.Name)' to '$($newName)'"
    $private.Name = $newName
  }
  
  property Legs {
    $private.Legs
  }
  
  method -override ToString {
    "A $($this.Class.ClassName) named $($this.name) with $($this.Legs) Legs"
  }

  method Speak {
    Throw "not implemented"
  }
} 

$DogClass = New-PSClass -inherit $AnimalClass Dog {
  note -static ObjectCount 0
  method -static DisplayObjectCount {
    "$($this.ClassName) has $($this.ObjectCount) instances"
  }

  constructor {
    param($DogName)
    Base $DogName 4   
 
    $DogClass.ObjectCount += 1
  }
 
  method -override ToString  {
    "$(Invoke-BaseClassMethod 'ToString') with fluf"
  }

  method -override Speak {
    "Arf"
  }

  method EatFood { 
	#[CmdletBinding()]
	param ( 
		#[parameter( Mandatory=$true, HelpMessage=”Food Kind is required”)]
		[String]
		[ValidateNotNullOrEmpty()]
		$FoodKind 
	)
  	"Doogy {0} is eating some {1}! - Yummy!" -f $this.Name, $FoodKind
  } 
}
 

$BirdClass = New-PSClass -inherit $AnimalClass Bird {
  note -static ObjectCount 0
  method -static DisplayObjectCount {
    "$($this.ClassName) has $($this.ObjectCount) instances"
  }
 

  constructor {
    Base $Args[0] 2  
 
    $BirdClass.ObjectCount += 1
  }
  
  method -override Speak {
    "Squawk"
  }
}
 
$Dog = $DogClass.New("Bowser")

$Dog.ToString()
$Dog.Name = "Duke"
$Dog.ToString()
$Dog.Speak()

$Bird = $BirdClass.New("Tweedy")
$Bird.ToString()
$Bird.Speak()

$DogClass.DisplayObjectCount()
$BirdClass.DisplayObjectCount()
$AnimalClass.DisplayObjectCount()

