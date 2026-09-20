<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_materialPriceHistory', function (Blueprint $table) {
            $table->bigIncrements('v_materialPriceHistoryId');

            $table->unsignedBigInteger('v_materialId');

            $table->decimal('v_oldPrice', 14, 2)
                ->nullable();

            $table->decimal('v_newPrice', 14, 2);

            $table->dateTime('v_effectiveDate')
                ->useCurrent();

            $table->string('v_changeReason', 255)
                ->nullable();

            $table->unsignedBigInteger('v_changedByUserId')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->foreign(
                'v_materialId',
                'fk_materialPriceHistory_material'
            )
                ->references('v_materialId')
                ->on('tbl_material')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_changedByUserId',
                'fk_materialPriceHistory_user'
            )
                ->references('v_userId')
                ->on('tbl_user')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_materialPriceHistory');
    }
};