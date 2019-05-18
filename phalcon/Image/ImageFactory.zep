
/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalconphp.com>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Image;

use Phalcon\Config;
use Phalcon\Helper\Arr;

/**
 * Phalcon\Image/ImageFactory
 */
class ImageFactory
{
    /**
     * @var array
     */
    private mapper = [];

    /**
     * @var array
     */
    private services = [];

    /**
     * TagFactory constructor.
     */
    public function __construct(array! services = [])
    {
        var adapters, name, service;
        
        /**
         * Available adapters
         */
        let adapters = [
            "gd"      : "\\Phalcon\\Image\\Adapter\\Gd",
            "imagick" : "\\Phalcon\\Image\\Adapter\\Imagick"
        ];

        let adapters = array_merge(adapters, services);

        for name, service in adapters {
            let this->mapper[name] = service;
            unset(this->services[name]);
        }
    }

    /**
     * Factory to create an instace from a Config object
     */
    public function load(var config) -> var
    {
        var height, file, name, width;

        if typeof config == "object" && config instanceof Config {
            let config = config->toArray();
        }

        if unlikely typeof config !== "array" {
            throw new Exception(
                "Config must be array or Phalcon\\Config object"
            );
        }

        if unlikely !isset config["adapter"] {
            throw new Exception(
                "You must provide 'adapter' option in factory config parameter."
            );
        }

        if unlikely !isset config["file"] {
            throw new Exception(
                "You must provide 'file' option in factory config parameter."
            );
        }

        let name = config["adapter"];

        unset config["adapter"];

        let file   = Arr::get(config, "file"),
            height = Arr::get(config, "height", null),
            width  = Arr::get(config, "width", null);

        return this->newInstance(name, file, width, height);
    }

    /**
     * Creates a new instance
     */
    public function newInstance(
        string! name,
        string! file,
        int width = null,
        int height = null
    ) -> var
    {
        var definition;

        if !isset this->mapper[name] {
            throw new Exception("Service " . name . " is not registered");
        }

        if !isset this->services[name] {
            let definition           = this->mapper[name],
                this->services[name] = new {definition}(file, width, height);
        }

        return this->services[name];
    }
}
